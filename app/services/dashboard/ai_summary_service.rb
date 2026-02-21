module Dashboard
  class AiSummaryService
    GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent".freeze

    def initialize(account, stats_service, location: nil)
      @account = account
      @stats = stats_service
      @location = location
    end

    def cache_key_period
      key = @stats.period_key
      key += ":loc:#{@location.id}" if @location
      key
    end

    # Read from DB; generate in background if stale
    def fetch
      record = DashboardSummary.find_by(account: @account, period: cache_key_period)

      if record.nil? || record.stale?
        # Generate synchronously on first load, async after that
        if record.nil?
          generate_and_store!
          record = DashboardSummary.find_by(account: @account, period: cache_key_period)
        else
          GenerateDashboardSummaryJob.perform_later(@account.id, cache_key_period)
        end
      end

      record&.data
    end

    # Called by the job
    def generate_and_store!
      data = call_gemini
      return unless data

      record = DashboardSummary.find_or_initialize_by(account: @account, period: cache_key_period)
      record.update!(
        summary: data[:summary],
        strengths: data[:strengths],
        improvements: data[:improvements],
        action_item: data[:action_item],
        generated_at: Time.current
      )
    end

    private

    def call_gemini
      return nil unless ENV["GEMINI_API_KEY"].present?

      reviews = @stats.reviews.where.not(body: nil).recent.limit(50)
      return nil if reviews.count < 3

      review_texts = reviews.map { |r| "#{r.rating}★: #{r.body.truncate(200)}" }.join("\n")

      location_context = @location ? " for #{@location.name}" : ""

      prompt = <<~PROMPT
        You are a restaurant reputation analyst. Analyze these recent customer reviews#{location_context} and provide a brief, actionable summary for the restaurant owner.

        Reviews:
        #{review_texts}

        Stats:
        - Average rating: #{@stats.kpi_stats[:average_rating][:value]}
        - Total reviews in period: #{@stats.kpi_stats[:new_reviews]}
        - Sentiment score: #{@stats.kpi_stats[:sentiment_score][:value]}%

        Respond with ONLY valid JSON, no markdown:
        {
          "summary": "2-3 sentence executive summary of overall reputation",
          "strengths": ["strength 1", "strength 2", "strength 3"],
          "improvements": ["area 1", "area 2", "area 3"],
          "action_item": "One specific, actionable recommendation"
        }

        Keep it concise, practical, and specific to this restaurant's data. No generic advice.
      PROMPT

      response = http_call(prompt)
      parse_response(response)
    rescue => e
      Rails.logger.error "AI Summary generation failed: #{e.message}"
      nil
    end

    def http_call(prompt)
      uri = URI("#{GEMINI_URL}?key=#{ENV['GEMINI_API_KEY']}")
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.3 }
      }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 15) { |http| http.request(request) }
      JSON.parse(response.body)
    end

    def parse_response(response)
      content = response.dig("candidates", 0, "content", "parts", 0, "text")
      cleaned = content.to_s.gsub(/```json\s*/, "").gsub(/```\s*/, "").strip
      data = JSON.parse(cleaned)

      {
        summary: data["summary"],
        strengths: Array(data["strengths"]).first(3),
        improvements: Array(data["improvements"]).first(3),
        action_item: data["action_item"]
      }
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse AI summary: #{e.message}"
      nil
    end
  end
end

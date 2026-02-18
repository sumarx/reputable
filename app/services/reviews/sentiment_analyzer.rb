class Reviews::SentimentAnalyzer
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent".freeze

  def initialize(review)
    @review = review
  end

  def call
    return default_response unless @review.body.present?
    return default_response unless ENV["GEMINI_API_KEY"].present?

    begin
      response = analyze_with_gemini
      parse_response(response)
    rescue => error
      Rails.logger.error "Sentiment analysis failed for review #{@review.id}: #{error.message}"
      default_response
    end
  end

  private

  def analyze_with_gemini
    uri = URI("#{GEMINI_URL}?key=#{ENV['GEMINI_API_KEY']}")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = {
      contents: [{ parts: [{ text: sentiment_prompt }] }],
      generationConfig: { temperature: 0.1 }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def sentiment_prompt
    <<~PROMPT
      Analyze the sentiment of this restaurant review and categorize the mentioned aspects.
      
      Review: "#{@review.body}"
      
      Respond with ONLY valid JSON, no markdown, no explanation:
      {"sentiment": "positive", "score": 0.8, "categories": ["food", "service"]}
      
      Rules:
      - sentiment: must be "positive", "neutral", or "negative"
      - score: float from -1.0 (very negative) to 1.0 (very positive)
      - categories: only include aspects explicitly mentioned. Valid: food, service, atmosphere, value, cleanliness, location, staff, drinks, ambiance
    PROMPT
  end

  def parse_response(response)
    content = response.dig("candidates", 0, "content", "parts", 0, "text")
    # Strip markdown code fences if present
    cleaned = content.to_s.gsub(/```json\s*/, "").gsub(/```\s*/, "").strip
    data = JSON.parse(cleaned)

    {
      sentiment: data["sentiment"],
      score: data["score"].to_f.clamp(-1.0, 1.0),
      categories: Array(data["categories"]).select { |cat| valid_category?(cat) }
    }
  rescue JSON::ParserError => error
    Rails.logger.error "Failed to parse Gemini response: #{error.message} — raw: #{content}"
    default_response
  end

  def valid_category?(category)
    %w[food service atmosphere value cleanliness location staff drinks ambiance].include?(category.to_s.downcase)
  end

  def default_response
    { sentiment: "neutral", score: 0.0, categories: [] }
  end
end

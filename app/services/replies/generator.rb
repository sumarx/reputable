class Replies::Generator
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent".freeze

  def initialize(review, tone: "professional")
    @review = review
    @tone = tone
  end

  def call
    return fallback_replies unless @review.body.present?
    return fallback_replies unless ENV["GEMINI_API_KEY"].present?

    begin
      response = generate_with_gemini
      parse_response(response)
    rescue => error
      Rails.logger.error "Reply generation failed for review #{@review.id}: #{error.message}"
      fallback_replies
    end
  end

  private

  def generate_with_gemini
    uri = URI("#{GEMINI_URL}?key=#{ENV['GEMINI_API_KEY']}")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = {
      contents: [{ parts: [{ text: reply_prompt }] }],
      generationConfig: { temperature: 0.7 }
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    JSON.parse(response.body)
  end

  def reply_prompt
    location_name = @review.location.name
    rating_context = @review.rating ? "#{@review.rating}-star" : ""
    sentiment_context = @review.sentiment || "neutral"

    <<~PROMPT
      You are writing a #{@tone} reply to a #{rating_context} #{sentiment_context} restaurant review for #{location_name}.
      
      Review: "#{@review.body}"
      Customer: #{@review.reviewer_name || 'A valued customer'}
      
      Generate 3 different reply options in #{@tone} tone. Each reply should:
      - Thank the customer by name if available
      - Address their specific points (praise or concerns)
      - Be authentic and not overly promotional
      - Be 50-120 words long
      - If the review is in a non-English language, reply in the same language
      
      Respond with ONLY valid JSON, no markdown, no explanation:
      {"replies": ["First reply...", "Second reply...", "Third reply..."]}
    PROMPT
  end

  def parse_response(response)
    content = response.dig("candidates", 0, "content", "parts", 0, "text")
    cleaned = content.to_s.gsub(/```json\s*/, "").gsub(/```\s*/, "").strip
    data = JSON.parse(cleaned)

    replies = Array(data["replies"]).first(3).compact.map do |r|
      r.is_a?(Hash) ? (r["reply"] || r["text"] || r.values.first) : r
    end.select(&:present?)
  rescue JSON::ParserError => error
    Rails.logger.error "Failed to parse Gemini reply response: #{error.message}"
    fallback_replies
  end

  def fallback_replies
    customer_name = @review.reviewer_name || "there"
    location_name = @review.location.name

    case @review.sentiment
    when "positive"
      [
        "Thank you so much for your wonderful review! We're thrilled you had such a great experience at #{location_name}. We look forward to welcoming you back soon!",
        "Hi #{customer_name}! Your kind words mean the world to us. Thank you for sharing your positive experience at #{location_name}.",
        "Thank you for the fantastic review! It's customers like you who make our day at #{location_name}. We can't wait to serve you again!"
      ]
    when "negative"
      [
        "Thank you for your feedback, #{customer_name}. We sincerely apologize for not meeting your expectations. Please contact us directly so we can make this right.",
        "Hi #{customer_name}, we're sorry to hear about your experience. Your feedback is important to us and we'd love to discuss this further.",
        "Thank you for bringing this to our attention. We take all feedback seriously and would appreciate the opportunity to resolve this with you directly."
      ]
    else
      [
        "Thank you for your review, #{customer_name}! We appreciate you sharing your experience at #{location_name}.",
        "Hi #{customer_name}! Thanks for visiting #{location_name} and sharing your feedback. We hope to see you again soon!",
        "Thank you for your honest feedback about #{location_name}. We value all our customers' opinions."
      ]
    end
  end
end

class Replies::Generator
  def initialize(review, tone: "professional")
    @review = review
    @tone = tone
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def call
    return [] unless @review.body.present?

    begin
      response = generate_with_openai
      parse_response(response)
    rescue => error
      Rails.logger.error "Reply generation failed for review #{@review.id}: #{error.message}"
      fallback_replies
    end
  end

  private

  def generate_with_openai
    @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{
          role: "user",
          content: reply_prompt
        }],
        temperature: 0.7
      }
    )
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
      - Thank the customer
      - Address their specific concerns if negative
      - Invite them back or encourage others if positive
      - Be authentic and not overly promotional
      - Be 50-150 words long
      
      Respond with valid JSON:
      {
        "replies": [
          "First reply option...",
          "Second reply option...",
          "Third reply option..."
        ]
      }
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    data = JSON.parse(content)
    
    Array(data["replies"]).first(3).compact.select(&:present?)
  rescue JSON::ParserError => error
    Rails.logger.error "Failed to parse OpenAI reply response: #{error.message}"
    fallback_replies
  end

  def fallback_replies
    customer_name = @review.reviewer_name || "there"
    location_name = @review.location.name

    case @review.sentiment
    when "positive"
      [
        "Thank you so much for your wonderful review! We're thrilled you had such a great experience at #{location_name}. We look forward to welcoming you back soon!",
        "Hi #{customer_name}! Your kind words mean the world to us. Thank you for taking the time to share your positive experience at #{location_name}.",
        "Thank you for the fantastic review! It's customers like you who make our day at #{location_name}. We can't wait to serve you again!"
      ]
    when "negative"
      [
        "Thank you for your feedback, #{customer_name}. We sincerely apologize for not meeting your expectations. Please contact us directly so we can make this right.",
        "Hi #{customer_name}, we're sorry to hear about your experience. Your feedback is important to us and we'd love to discuss this further to improve our service.",
        "Thank you for bringing this to our attention. We take all feedback seriously and would appreciate the opportunity to resolve this matter with you directly."
      ]
    else
      [
        "Thank you for your review, #{customer_name}! We appreciate you taking the time to share your experience at #{location_name}.",
        "Hi #{customer_name}! Thanks for visiting #{location_name} and for sharing your feedback. We hope to see you again soon!",
        "Thank you for your honest feedback about #{location_name}. We value all our customers' opinions and experiences."
      ]
    end
  end
end
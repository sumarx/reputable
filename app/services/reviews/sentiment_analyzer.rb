class Reviews::SentimentAnalyzer
  def initialize(review)
    @review = review
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def call
    return default_response unless @review.body.present?

    begin
      response = analyze_with_openai
      parse_response(response)
    rescue => error
      Rails.logger.error "Sentiment analysis failed for review #{@review.id}: #{error.message}"
      default_response
    end
  end

  private

  def analyze_with_openai
    @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{
          role: "user",
          content: sentiment_prompt
        }],
        temperature: 0.1
      }
    )
  end

  def sentiment_prompt
    <<~PROMPT
      Analyze the sentiment of this restaurant review and categorize the mentioned aspects.
      
      Review: "#{@review.body}"
      
      Please respond with valid JSON in exactly this format:
      {
        "sentiment": "positive|neutral|negative",
        "score": -1.0 to 1.0,
        "categories": ["food", "service", "atmosphere", "value", "cleanliness", "location"]
      }
      
      Categories should only include aspects explicitly mentioned in the review.
    PROMPT
  end

  def parse_response(response)
    content = response.dig("choices", 0, "message", "content")
    data = JSON.parse(content)
    
    {
      sentiment: data["sentiment"],
      score: data["score"].to_f.clamp(-1.0, 1.0),
      categories: Array(data["categories"]).select { |cat| valid_category?(cat) }
    }
  rescue JSON::ParserError => error
    Rails.logger.error "Failed to parse OpenAI response: #{error.message}"
    default_response
  end

  def valid_category?(category)
    %w[food service atmosphere value cleanliness location staff drinks ambiance].include?(category.downcase)
  end

  def default_response
    {
      sentiment: "neutral",
      score: 0.0,
      categories: []
    }
  end
end
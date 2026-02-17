class AnalyzeSentimentJob < ApplicationJob
  queue_as :default

  def perform(review)
    return unless review.is_a?(Review)

    # Set the tenant for multi-tenancy
    ActsAsTenant.with_tenant(review.account) do
      analyzer = Reviews::SentimentAnalyzer.new(review)
      result = analyzer.call

      review.update!(
        sentiment: result[:sentiment],
        sentiment_score: result[:score],
        categories: result[:categories]
      )

      Rails.logger.info "Analyzed sentiment for review #{review.id}: #{result[:sentiment]} (#{result[:score]})"
    end
  rescue => error
    Rails.logger.error "AnalyzeSentimentJob failed for review #{review.id}: #{error.message}"
    raise error
  end
end
class AnalyticsController < ApplicationController
  before_action :resume_session

  def show
    @reviews = Current.account.reviews
    @total_reviews = @reviews.count
    @average_rating = @reviews.where.not(rating: nil).average(:rating)&.round(2) || 0
    @positive_count = @reviews.positive.count
    @negative_count = @reviews.negative.count
    @neutral_count = @reviews.neutral.count

    @rating_trend = @reviews.where("published_at > ?", 90.days.ago).where.not(rating: nil).group_by_week(:published_at).average(:rating)
    @reviews_by_platform = @reviews.group(:platform).count
    @reviews_by_sentiment = @reviews.where.not(sentiment: nil).group(:sentiment).count
    @reviews_over_time = @reviews.where("published_at > ?", 90.days.ago).group_by_week(:published_at).count
    @rating_distribution = @reviews.where.not(rating: nil).group(:rating).count

    @locations = Current.account.locations.includes(:reviews)
  end
end

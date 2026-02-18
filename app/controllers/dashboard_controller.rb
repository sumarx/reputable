class DashboardController < ApplicationController
  before_action :resume_session
  
  def show
    @account = Current.account
    @stats = calculate_stats
    @recent_reviews = Current.account.reviews.recent.includes(:location).limit(10)
    @rating_trend_data = rating_trend_data
    @campaigns = Current.account.campaigns.active.includes(:location)
    @campaign_stats = calculate_campaign_stats
  end

  private

  def calculate_stats
    reviews = Current.account.reviews
    
    {
      total_reviews: reviews.count,
      average_rating: reviews.where.not(rating: nil).average(:rating)&.round(2) || 0,
      response_rate: calculate_response_rate,
      sentiment_score: calculate_sentiment_score
    }
  end

  def calculate_response_rate
    total = Current.account.reviews.count
    return 0 if total.zero?
    
    replied = Current.account.reviews.replied.count
    ((replied.to_f / total) * 100).round(1)
  end

  def calculate_sentiment_score
    reviews_with_sentiment = Current.account.reviews.where.not(sentiment_score: nil)
    return 0 if reviews_with_sentiment.empty?
    
    (reviews_with_sentiment.average(:sentiment_score) * 100).round(1)
  end

  def calculate_campaign_stats
    campaigns = Current.account.campaigns
    responses = CampaignResponse.joins(:campaign).where(campaigns: { account_id: Current.account.id })
    {
      active_campaigns: campaigns.active.count,
      total_responses: responses.count,
      total_redirects: responses.where(outcome: 'redirect').count,
      total_clicked: responses.where(clicked_external: true).count,
      recent_responses: responses.order(created_at: :desc).limit(5).includes(campaign: :location)
    }
  end

  def rating_trend_data
    Current.account.reviews
      .where('published_at > ?', 30.days.ago)
      .where.not(rating: nil)
      .group_by_day(:published_at)
      .average(:rating)
  end
end
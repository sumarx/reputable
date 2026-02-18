class Review < ApplicationRecord
  acts_as_tenant(:account)
  
  belongs_to :location
  belongs_to :account
  has_many :reply_drafts, dependent: :destroy

  validates :location, presence: true
  validates :account, presence: true
  validates :platform, presence: true, inclusion: { in: %w[google facebook tripadvisor yelp] }
  validates :external_review_id, presence: true, uniqueness: { scope: [:account_id, :platform] }
  validates :rating, numericality: { in: 1..5 }, allow_nil: true
  validates :reply_status, inclusion: { in: %w[pending draft approved sent manual] }
  validates :sentiment, inclusion: { in: %w[positive neutral negative] }, allow_nil: true
  validates :sentiment_score, numericality: { in: -1.0..1.0 }, allow_nil: true

  scope :recent, -> { order(published_at: :desc) }
  scope :by_platform, ->(platform) { where(platform: platform) }
  scope :by_sentiment, ->(sentiment) { where(sentiment: sentiment) }
  scope :positive, -> { where(sentiment: 'positive') }
  scope :negative, -> { where(sentiment: 'negative') }
  scope :neutral, -> { where(sentiment: 'neutral') }
  scope :with_rating, ->(rating) { where(rating: rating) }
  scope :high_rating, -> { where(rating: 4..5) }
  scope :low_rating, -> { where(rating: 1..3) }
  scope :replied, -> { where(reply_status: %w[sent manual]) }
  scope :unreplied, -> { where.not(reply_status: %w[sent manual]) }
  scope :published_after, ->(date) { where('published_at > ?', date) }
  scope :published_before, ->(date) { where('published_at < ?', date) }

  after_create :analyze_sentiment_async
  after_create :update_location_stats

  def positive?
    sentiment == 'positive'
  end

  def negative?
    sentiment == 'negative'
  end

  def neutral?
    sentiment == 'neutral'
  end

  def replied?
    reply_status.in?(%w[sent manual])
  end

  def needs_reply?
    negative? && !replied?
  end

  def platform_icon
    case platform
    when 'google' then '🌐'
    when 'facebook' then '📘'
    when 'tripadvisor' then '🧳'
    when 'yelp' then '🍽️'
    else '⭐'
    end
  end

  def star_rating
    return '—' unless rating
    
    '★' * rating + '☆' * (5 - rating)
  end

  private

  def analyze_sentiment_async
    AnalyzeSentimentJob.perform_later(self)
  end

  def update_location_stats
    location.update_stats!
  end
end
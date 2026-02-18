class Campaign < ApplicationRecord
  acts_as_tenant(:account)
  
  belongs_to :location
  belongs_to :account
  has_many :campaign_responses, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :campaign_type, inclusion: { in: %w[qr email sms] }
  validates :positive_threshold, numericality: { in: 1..5 }
  validates :redirect_platform, inclusion: { in: %w[google facebook tripadvisor yelp] }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(campaign_type: type) }

  before_validation :generate_slug, on: :create

  def conversion_rate
    return 0 if responses_count.zero?
    
    (redirects_count.to_f / responses_count * 100).round(1)
  end

  def positive_responses
    campaign_responses.where('rating >= ?', positive_threshold)
  end

  def negative_responses
    campaign_responses.where('rating < ?', positive_threshold)
  end

  def qr_code_url
    host = ENV['APP_HOST'] || 'sumarx.sajjadumar.dev'
    "https://#{host}/c/#{slug}"
  end

  private

  def generate_slug
    return if slug.present?
    
    base_slug = "#{location.name.parameterize}-#{name.parameterize}"
    counter = 1
    potential_slug = base_slug

    while Campaign.exists?(slug: potential_slug)
      potential_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = potential_slug
  end
end
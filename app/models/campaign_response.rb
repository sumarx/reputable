class CampaignResponse < ApplicationRecord
  belongs_to :campaign

  validates :rating, numericality: { in: 1..5 }, allow_nil: false
  validates :outcome, inclusion: { in: %w[positive negative redirect private] }

  scope :positive, -> { where(outcome: 'positive') }
  scope :negative, -> { where(outcome: 'negative') }
  scope :redirected, -> { where(outcome: 'redirect') }

  before_validation :determine_outcome, on: :create
  after_create :update_campaign_counters

  def positive?
    rating >= campaign.positive_threshold
  end

  def negative?
    rating < campaign.positive_threshold
  end

  private

  def update_campaign_counters
    campaign.increment!(:responses_count)
    campaign.increment!(:redirects_count) if outcome == 'redirect'
  end

  def determine_outcome
    self.outcome = positive? ? 'redirect' : 'private'
  end
end
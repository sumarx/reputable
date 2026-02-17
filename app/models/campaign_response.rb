class CampaignResponse < ApplicationRecord
  belongs_to :campaign

  validates :rating, numericality: { in: 1..5 }, allow_nil: false
  validates :outcome, inclusion: { in: %w[positive negative redirect private] }

  scope :positive, -> { where(outcome: 'positive') }
  scope :negative, -> { where(outcome: 'negative') }
  scope :redirected, -> { where(outcome: 'redirect') }

  after_create :update_campaign_counters
  after_create :determine_outcome

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
    if positive?
      update!(outcome: 'redirect')
    else
      update!(outcome: 'private')
    end
  end
end
class CampaignResponse < ApplicationRecord
  belongs_to :campaign

  validates :rating, numericality: { in: 1..5 }, allow_nil: false
  validates :outcome, inclusion: { in: %w[positive negative redirect private] }

  scope :positive, -> { where(outcome: 'positive') }
  scope :negative, -> { where(outcome: 'negative') }
  scope :redirected, -> { where(outcome: 'redirect') }

  before_validation :determine_outcome, on: :create
  after_create :update_campaign_counters
  after_create_commit :notify_negative_review

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

  def notify_negative_review
    return unless outcome.in?(%w[private negative])

    account = campaign.account

    # Email notifications
    account.users.each do |user|
      next unless user.notification_settings&.email_on_negative?

      ReviewMailer.negative_review_alert(self, user).deliver_later
    end

    # Slack notification
    if account.notify_slack? && account.slack_webhook_url.present?
      Notifications::SlackNotifier.send(
        account.slack_webhook_url,
        "⚠️ New negative feedback (#{rating}★) at #{campaign.location.name}\n> #{feedback}"
      )
    end
  end
end
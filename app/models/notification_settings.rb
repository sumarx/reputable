class NotificationSettings < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :phone_number, format: { with: /\A\+?[1-9]\d{1,14}\z/ }, allow_blank: true
  validates :slack_webhook_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  def notifications_enabled?
    email_on_negative || email_daily_digest || sms_on_negative || slack_webhook_enabled
  end

  def sms_enabled?
    sms_on_negative && phone_number.present?
  end

  def slack_enabled?
    slack_webhook_enabled && slack_webhook_url.present?
  end
end
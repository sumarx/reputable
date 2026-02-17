class User < ApplicationRecord
  acts_as_tenant(:account)
  
  belongs_to :account
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :notification_settings, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_digest, presence: true
  validates :role, inclusion: { in: %w[admin member] }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create :create_notification_settings

  private

  def create_notification_settings
    NotificationSettings.create!(user: self)
  end
end

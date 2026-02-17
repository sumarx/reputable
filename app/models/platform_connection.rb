class PlatformConnection < ApplicationRecord
  belongs_to :location

  encrypts :access_token_ciphertext, :refresh_token_ciphertext

  validates :location, presence: true
  validates :platform, presence: true, inclusion: { in: %w[google facebook tripadvisor yelp] }
  validates :status, inclusion: { in: %w[active inactive error] }
  validates :platform, uniqueness: { scope: :location_id }

  scope :active, -> { where(status: 'active') }
  scope :by_platform, ->(platform) { where(platform: platform) }

  def active?
    status == 'active'
  end

  def needs_refresh?
    token_expires_at.present? && token_expires_at < 1.hour.from_now
  end
end
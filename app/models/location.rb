class Location < ApplicationRecord
  acts_as_tenant(:account)
  
  belongs_to :account
  has_many :platform_connections, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  validates :name, presence: true
  validates :account, presence: true

  scope :with_connections, -> { joins(:platform_connections) }
  scope :active, -> { where(active: true) }

  def full_address
    [address, city, country].compact.join(', ')
  end

  def connected_platforms
    platform_connections.active.pluck(:platform).uniq
  end

  def update_stats!
    self.total_reviews = reviews.count
    self.average_rating = reviews.where.not(rating: nil).average(:rating).to_f.round(2)
    save!
  end
end
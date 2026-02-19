class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :max_locations, presence: true, numericality: { greater_than: 0 }
  validates :max_campaigns, presence: true, numericality: { greater_than_or_equal_to: -1 }
  validates :max_reviews_per_month, presence: true, numericality: { greater_than_or_equal_to: -1 }
  validates :position, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position) }

  def price_formatted
    "#{currency} #{(price_cents / 100.0).to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end

  def unlimited_reviews?
    max_reviews_per_month == -1
  end

  def feature_enabled?(feature)
    features[feature.to_s] == true
  end
end

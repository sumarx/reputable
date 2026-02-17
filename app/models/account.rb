class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :campaigns, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :plan, presence: true, inclusion: { in: %w[starter professional enterprise] }
  validates :subscription_status, presence: true, inclusion: { in: %w[trialing active canceled past_due] }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    
    self.slug = name.parameterize if name.present?
  end
end
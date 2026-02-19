class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :payment_proofs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :plan, presence: true, inclusion: { in: %w[starter professional enterprise] }
  validates :subscription_status, presence: true, inclusion: { in: %w[trialing active canceled past_due] }

  before_validation :generate_slug, on: :create

  delegate :active?, :on_trial?, :past_due?, :suspended?, :trial_ending_soon?, 
           :days_until_trial_ends, :grace_period_ends_at, :in_grace_period?, 
           to: :subscription, allow_nil: true

  def billing_locked?
    subscription&.suspended? || (!subscription&.active? && !subscription&.in_grace_period?)
  end

  def show_trial_warning?
    subscription&.trial_ending_soon?
  end

  def show_past_due_warning?
    subscription&.past_due? && subscription&.in_grace_period?
  end

  def show_suspended_warning?
    subscription&.suspended?
  end

  private

  def generate_slug
    return if slug.present?
    
    self.slug = name.parameterize if name.present?
  end
end
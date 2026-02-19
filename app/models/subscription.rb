class Subscription < ApplicationRecord
  belongs_to :account
  belongs_to :plan
  has_many :invoices, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[trial active past_due suspended cancelled] }

  scope :active, -> { where(status: ['trial', 'active']) }
  scope :past_due, -> { where(status: 'past_due') }
  scope :trial_ending, -> { where(status: 'trial').where('trial_ends_at <= ?', 3.days.from_now) }

  def active?
    status.in?(['trial', 'active'])
  end

  def on_trial?
    status == 'trial'
  end

  def past_due?
    status == 'past_due'
  end

  def suspended?
    status == 'suspended'
  end

  def trial_ending_soon?
    on_trial? && trial_ends_at && trial_ends_at <= 3.days.from_now
  end

  def days_until_trial_ends
    return 0 unless on_trial? && trial_ends_at
    
    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  def grace_period_ends_at
    return nil unless past_due? && current_period_end
    
    current_period_end + 7.days
  end

  def in_grace_period?
    past_due? && grace_period_ends_at && Time.current <= grace_period_ends_at
  end
end

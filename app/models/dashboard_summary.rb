class DashboardSummary < ApplicationRecord
  belongs_to :account

  validates :period, presence: true, uniqueness: { scope: :account_id }
  validates :summary, presence: true

  def stale?
    generated_at.nil? || generated_at < 24.hours.ago
  end

  def data
    {
      summary: summary,
      strengths: strengths || [],
      improvements: improvements || [],
      action_item: action_item
    }
  end
end

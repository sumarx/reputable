class ReplyDraft < ApplicationRecord
  belongs_to :review

  validates :body, presence: true
  validates :tone, inclusion: { in: %w[professional friendly apologetic] }
  validates :status, inclusion: { in: %w[draft approved rejected] }

  scope :by_tone, ->(tone) { where(tone: tone) }
  scope :draft, -> { where(status: 'draft') }
  scope :approved, -> { where(status: 'approved') }

  def approved?
    status == 'approved'
  end

  def draft?
    status == 'draft'
  end
end
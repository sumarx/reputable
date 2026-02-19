class PaymentProof < ApplicationRecord
  belongs_to :invoice
  belongs_to :account
  has_one_attached :file

  validates :status, presence: true, inclusion: { in: %w[pending_review approved rejected] }
  validates :submitted_at, presence: true
  validates :file, presence: true

  validate :file_type_validation

  scope :pending_review, -> { where(status: 'pending_review') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }

  def pending_review?
    status == 'pending_review'
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def approve!(admin_notes: nil)
    transaction do
      update!(
        status: 'approved',
        reviewed_at: Time.current,
        admin_notes: admin_notes
      )
      
      invoice.mark_as_paid!(
        payment_method: 'bank_transfer',
        notes: "Payment approved via proof ##{id}"
      )
      
      # Update subscription status
      invoice.subscription.update!(status: 'active') if invoice.subscription.past_due?
    end
  end

  def reject!(admin_notes:)
    update!(
      status: 'rejected',
      reviewed_at: Time.current,
      admin_notes: admin_notes
    )
  end

  private

  def file_type_validation
    return unless file.attached?

    unless file.content_type.in?(%w[image/jpeg image/png image/gif application/pdf])
      errors.add(:file, 'must be a JPEG, PNG, GIF, or PDF file')
    end
  end
end

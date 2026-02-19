class Invoice < ApplicationRecord
  belongs_to :account
  belongs_to :subscription
  has_many :payment_proofs, dependent: :destroy
  has_one :latest_payment_proof, -> { order(created_at: :desc) }, class_name: 'PaymentProof'

  validates :number, presence: true, uniqueness: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending paid overdue cancelled] }
  validates :issued_at, :due_at, presence: true

  scope :pending, -> { where(status: 'pending') }
  scope :paid, -> { where(status: 'paid') }
  scope :overdue, -> { where(status: 'overdue') }
  scope :overdue_candidates, -> { where(status: 'pending').where('due_at < ?', Date.current) }

  before_validation :generate_number, on: :create

  def amount_formatted
    "#{currency} #{number_with_comma(amount_cents / 100)}"
  end

  private

  def number_with_comma(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def overdue?
    status == 'overdue' || (status == 'pending' && due_at < Date.current)
  end

  def paid?
    status == 'paid'
  end

  def pending?
    status == 'pending'
  end

  def days_overdue
    return 0 unless overdue?
    
    (Date.current - due_at).to_i
  end

  def mark_as_paid!(payment_method: nil, payment_reference: nil, notes: nil)
    update!(
      status: 'paid',
      paid_at: Time.current,
      payment_method: payment_method,
      payment_reference: payment_reference,
      notes: notes
    )
  end

  private

  def generate_number
    return if number.present?
    
    year = Date.current.year
    sequence = Invoice.where('number LIKE ?', "INV-#{year}-%").count + 1
    self.number = "INV-#{year}-#{sequence.to_s.rjust(4, '0')}"
  end
end

class Billing::CheckOverdueJob < ApplicationJob
  queue_as :default

  def perform
    # Mark invoices as overdue
    overdue_invoices = Invoice.overdue_candidates.includes(:account, :subscription)
    
    overdue_invoices.find_each do |invoice|
      invoice.update!(status: 'overdue')
      
      # Update subscription status to past_due
      invoice.subscription.update!(status: 'past_due') if invoice.subscription.active?
      
      # Send reminder email
      BillingMailer.payment_reminder(invoice).deliver_later
      
      Rails.logger.info "Marked invoice #{invoice.number} as overdue"
    end

    Rails.logger.info "Checked #{overdue_invoices.count} invoices for overdue status"
  end
end
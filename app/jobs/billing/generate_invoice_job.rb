class Billing::GenerateInvoiceJob < ApplicationJob
  queue_as :default

  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)
    return unless subscription.active?

    # Calculate next period
    current_end = subscription.current_period_end || Date.current
    next_start = current_end + 1.day
    next_end = next_start + 1.month - 1.day

    # Create invoice
    invoice = subscription.invoices.create!(
      account: subscription.account,
      amount_cents: subscription.plan.price_cents,
      currency: subscription.plan.currency,
      status: 'pending',
      issued_at: Date.current,
      due_at: Date.current + 7.days
    )

    # Update subscription period
    subscription.update!(
      current_period_start: next_start,
      current_period_end: next_end
    )

    # Send notification email
    BillingMailer.invoice_generated(invoice).deliver_later

    Rails.logger.info "Generated invoice #{invoice.number} for subscription #{subscription.id}"
  end
end
class Billing::SuspendAccountJob < ApplicationJob
  queue_as :default

  def perform
    # Find accounts that should be suspended (7 days after overdue)
    suspend_date = Date.current - 7.days
    
    subscriptions_to_suspend = Subscription.joins(:invoices)
                                         .where(status: 'past_due')
                                         .where(invoices: { status: 'overdue', due_at: ..suspend_date })
                                         .distinct
                                         .includes(:account)

    subscriptions_to_suspend.find_each do |subscription|
      # Check if there are any recent approved payment proofs
      recent_approved_proofs = PaymentProof.joins(:invoice)
                                          .where(invoices: { subscription: subscription })
                                          .where(status: 'approved')
                                          .where('payment_proofs.reviewed_at > ?', 24.hours.ago)

      if recent_approved_proofs.empty?
        subscription.update!(status: 'suspended')
        
        # Send suspension notice
        BillingMailer.account_suspended(subscription.account).deliver_later
        
        Rails.logger.info "Suspended account #{subscription.account.id} (#{subscription.account.name})"
      end
    end

    Rails.logger.info "Checked #{subscriptions_to_suspend.count} accounts for suspension"
  end
end
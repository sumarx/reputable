# Preview all emails at http://localhost:3000/rails/mailers/billing_mailer
class BillingMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/billing_mailer/invoice_generated
  def invoice_generated
    BillingMailer.invoice_generated
  end

  # Preview this email at http://localhost:3000/rails/mailers/billing_mailer/payment_reminder
  def payment_reminder
    BillingMailer.payment_reminder
  end

  # Preview this email at http://localhost:3000/rails/mailers/billing_mailer/account_suspended
  def account_suspended
    BillingMailer.account_suspended
  end

  # Preview this email at http://localhost:3000/rails/mailers/billing_mailer/payment_confirmed
  def payment_confirmed
    BillingMailer.payment_confirmed
  end

  # Preview this email at http://localhost:3000/rails/mailers/billing_mailer/payment_proof_submitted
  def payment_proof_submitted
    BillingMailer.payment_proof_submitted
  end
end

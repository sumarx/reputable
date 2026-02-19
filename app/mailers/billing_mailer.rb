class BillingMailer < ApplicationMailer
  default from: "RepuTable Billing <sumarx747@gmail.com>"

  def invoice_generated(invoice)
    @invoice = invoice
    @account = invoice.account
    @user = @account.users.first # Primary user for the account
    
    mail(
      to: @user.email_address,
      subject: "New Invoice #{@invoice.number} - RepuTable"
    )
  end

  def payment_reminder(invoice)
    @invoice = invoice
    @account = invoice.account
    @user = @account.users.first
    
    mail(
      to: @user.email_address,
      subject: "Payment Reminder: Invoice #{@invoice.number} - RepuTable"
    )
  end

  def account_suspended(account)
    @account = account
    @user = account.users.first
    
    mail(
      to: @user.email_address,
      subject: "Account Suspended - RepuTable"
    )
  end

  def payment_confirmed(invoice)
    @invoice = invoice
    @account = invoice.account
    @user = @account.users.first
    
    mail(
      to: @user.email_address,
      subject: "Payment Confirmed: Invoice #{@invoice.number} - RepuTable"
    )
  end

  def payment_proof_submitted(payment_proof)
    @payment_proof = payment_proof
    @invoice = payment_proof.invoice
    @account = payment_proof.account
    
    # Send to admin email for review
    mail(
      to: "sumarx747@gmail.com",
      subject: "Payment Proof Submitted: Invoice #{@invoice.number} - RepuTable"
    )
  end
end

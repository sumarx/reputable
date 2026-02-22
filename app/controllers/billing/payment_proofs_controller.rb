class Billing::PaymentProofsController < ApplicationController
  before_action :set_invoice, only: [:create]

  def create
    @payment_proof = @invoice.payment_proofs.build(payment_proof_params)
    @payment_proof.account = Current.account
    @payment_proof.submitted_at = Time.current

    if @payment_proof.save
      # Send notification email to admin
      BillingMailer.payment_proof_submitted(@payment_proof).deliver_later
      
      redirect_to billing_invoice_path(@invoice), status: :see_other, 
        notice: "Payment proof uploaded successfully. We'll review it within 24 hours."
    else
      @bank_details = {
        bank_name: "Meezan Bank",
        account_title: "Sajjad Umar",
        account_number: ENV['BILLING_BANK_ACCOUNT'],
        iban: ENV['BILLING_BANK_IBAN']
      }
      @existing_proof = @invoice.latest_payment_proof
      
      render 'billing/invoices/show', status: :unprocessable_entity
    end
  end

  private

  def set_invoice
    @invoice = Current.account.invoices.find(params[:invoice_id])
  end

  def payment_proof_params
    params.require(:payment_proof).permit(:file)
  end
end
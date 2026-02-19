class Billing::InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show]

  def index
    @invoices = Current.account.invoices.order(created_at: :desc)
                      .includes(:subscription, :payment_proofs)
  end

  def show
    @payment_proof = @invoice.payment_proofs.build
    @existing_proof = @invoice.latest_payment_proof
    @bank_details = {
      bank_name: "Meezan Bank",
      account_title: "Sajjad Umar",
      account_number: ENV['BILLING_BANK_ACCOUNT'],
      iban: ENV['BILLING_BANK_IBAN']
    }
  end

  private

  def set_invoice
    @invoice = Current.account.invoices.find(params[:id])
  end
end
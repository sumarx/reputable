class Billing::OverviewController < ApplicationController
  def show
    @account = Current.account
    @subscription = @account.subscription
    @current_plan = @subscription&.plan
    @recent_invoices = @account.invoices.order(created_at: :desc).limit(5)
    @next_invoice_date = @subscription&.current_period_end
    @usage_stats = calculate_usage_stats
  end

  private

  def calculate_usage_stats
    {
      locations: @account.locations.count,
      campaigns: @account.campaigns.count,
      reviews_this_month: @account.reviews.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    }
  end
end
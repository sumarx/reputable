class DashboardController < ApplicationController
  before_action :resume_session
  include LocationFilterable

  def show
    @account = Current.account
    @period = params[:period] || "30d"
    @stats_service = Dashboard::StatsService.new(@account, period: @period, location: @current_location)

    @kpi = @stats_service.kpi_stats
    @recent_reviews = @stats_service.recent_reviews
    @campaigns = Current.account.campaigns.active.includes(:location)
    @campaign_stats = calculate_campaign_stats

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def calculate_campaign_stats
    campaigns = @current_location ? @current_location.campaigns : Current.account.campaigns
    responses = CampaignResponse.joins(:campaign).where(campaigns: { account_id: Current.account.id })
    responses = responses.where(campaigns: { location_id: @current_location.id }) if @current_location
    {
      active_campaigns: campaigns.active.count,
      total_responses: responses.count,
      total_redirects: responses.where(outcome: "redirect").count,
      total_clicked: responses.where(clicked_external: true).count,
      recent_responses: responses.order(created_at: :desc).limit(5).includes(campaign: :location)
    }
  end
end

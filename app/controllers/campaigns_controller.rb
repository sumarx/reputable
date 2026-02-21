class CampaignsController < ApplicationController
  before_action :resume_session
  include LocationFilterable
  before_action :set_campaign, only: [:show, :edit, :update, :destroy, :qr_code]

  def index
    @campaigns = Current.account.campaigns.includes(:location, :campaign_responses)
  end

  def analytics
    @period = params[:period] || "30d"
    @analytics = Campaigns::AnalyticsService.new(Current.account, period: @period, location: @current_location)
  end

  def show
    @responses = @campaign.campaign_responses.order(created_at: :desc).limit(20)
  end

  def new
    @campaign = Current.account.campaigns.build
    @locations = Current.account.locations
  end

  def create
    @campaign = Current.account.campaigns.build(campaign_params)
    
    if @campaign.save
      redirect_to @campaign, notice: 'Campaign was successfully created.'
    else
      @locations = Current.account.locations
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @locations = Current.account.locations
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to @campaign, notice: 'Campaign was successfully updated.'
    else
      @locations = Current.account.locations
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: 'Campaign was successfully deleted.'
  end

  def qr_code
    generator = Campaigns::QrGenerator.new(@campaign)
    svg = generator.call
    
    if svg
      render plain: svg, content_type: 'image/svg+xml'
    else
      head :not_found
    end
  end

  private

  def set_campaign
    @campaign = Current.account.campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :location_id, :campaign_type, :positive_threshold, :redirect_platform, :active)
  end
end
class CampaignResponsesController < ApplicationController
  before_action :resume_session

  def show
    @campaign = Current.account.campaigns.find(params[:campaign_id])
    @response = @campaign.campaign_responses.find(params[:id])
  end
end

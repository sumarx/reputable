class PublicCampaignsController < ApplicationController
  allow_unauthenticated_access
  layout false
  before_action :set_campaign

  def show
    @campaign_response = @campaign.campaign_responses.build
    @location = @campaign.location
  end

  def respond
    @campaign_response = @campaign.campaign_responses.build(campaign_response_params)
    @location = @campaign.location

    if @campaign_response.save
      if @campaign_response.positive?
        @redirect_url = review_platform_url
        render :redirect_to_review
      else
        render :thank_you
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  def track_click
    response = @campaign.campaign_responses.find_by(id: params[:response_id])
    if response
      response.update(clicked_external: true)
      head :ok
    else
      head :not_found
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found, layout: false
  end

  def campaign_response_params
    params.require(:campaign_response).permit(:rating, :feedback, :customer_name, :customer_phone)
  end

  def review_platform_url
    location = @campaign.location

    case @campaign.redirect_platform
    when "google"
      google_review_url(location)
    when "facebook"
      facebook_review_url(location)
    when "tripadvisor"
      tripadvisor_review_url(location)
    when "yelp"
      yelp_review_url(location)
    else
      google_review_url(location)
    end
  end

  def google_review_url(location)
    if location.google_place_id.present?
      "https://search.google.com/local/writereview?placeid=#{location.google_place_id}"
    else
      "https://www.google.com/search?q=#{URI.encode_www_form_component(location.name + ' ' + (location.full_address || ''))}"
    end
  end

  def facebook_review_url(location)
    if location.facebook_page_id.present?
      "https://www.facebook.com/#{location.facebook_page_id}/reviews"
    else
      "https://www.facebook.com/search/top/?q=#{URI.encode_www_form_component(location.name)}"
    end
  end

  def tripadvisor_review_url(location)
    if location.tripadvisor_id.present?
      "https://www.tripadvisor.com/UserReviewEdit-#{location.tripadvisor_id}"
    else
      "https://www.tripadvisor.com/"
    end
  end

  def yelp_review_url(location)
    "https://www.yelp.com/writeareview/biz/#{location.name.parameterize}"
  end
end

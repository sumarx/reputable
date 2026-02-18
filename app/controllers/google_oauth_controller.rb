class GoogleOauthController < ApplicationController
  before_action :resume_session

  def connect
    location_id = params[:location_id]
    session[:google_oauth_location_id] = location_id

    params_hash = {
      client_id: ENV["GOOGLE_OAUTH_CLIENT_ID"],
      redirect_uri: "https://sumarx.sajjadumar.dev/auth/google/callback",
      response_type: "code",
      scope: "https://www.googleapis.com/auth/business.manage",
      access_type: "offline",
      prompt: "consent",
      state: location_id
    }

    redirect_to "https://accounts.google.com/o/oauth2/v2/auth?#{params_hash.to_query}", allow_other_host: true
  end

  def callback
    location_id = params[:state] || session[:google_oauth_location_id]
    location = Current.account.locations.find(location_id)

    # Exchange code for tokens
    uri = URI("https://oauth2.googleapis.com/token")
    response = Net::HTTP.post_form(uri, {
      code: params[:code],
      client_id: ENV["GOOGLE_OAUTH_CLIENT_ID"],
      client_secret: ENV["GOOGLE_OAUTH_CLIENT_SECRET"],
      redirect_uri: "https://sumarx.sajjadumar.dev/auth/google/callback",
      grant_type: "authorization_code"
    })

    data = JSON.parse(response.body)

    if data["error"]
      redirect_to location_path(location), alert: "Google OAuth failed: #{data["error_description"] || data["error"]}"
      return
    end

    location.update!(
      google_oauth_token: data["access_token"],
      google_oauth_refresh_token: data["refresh_token"],
      google_oauth_expires_at: Time.current + data["expires_in"].to_i.seconds,
      google_connected: true
    )

    # Try to fetch account/location IDs
    fetch_google_business_ids(location, data["access_token"])

    session.delete(:google_oauth_location_id)
    redirect_to location_path(location), notice: "Google Business Profile connected successfully!"
  end

  def disconnect
    location = Current.account.locations.find(params[:location_id])
    location.update!(
      google_oauth_token: nil,
      google_oauth_refresh_token: nil,
      google_oauth_expires_at: nil,
      google_account_id: nil,
      google_location_id: nil,
      google_connected: false
    )
    redirect_to location_path(location), notice: "Google Business Profile disconnected."
  end

  private

  def fetch_google_business_ids(location, access_token)
    # Fetch accounts
    uri = URI("https://mybusinessaccountmanagement.googleapis.com/v1/accounts")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
    data = JSON.parse(response.body)

    accounts = data["accounts"] || []
    return if accounts.empty?

    # For each account, try to find locations
    accounts.each do |account|
      account_name = account["name"] # e.g. "accounts/123"
      loc_uri = URI("https://mybusinessbusinessinformation.googleapis.com/v1/#{account_name}/locations?readMask=name,title")
      loc_request = Net::HTTP::Get.new(loc_uri)
      loc_request["Authorization"] = "Bearer #{access_token}"

      loc_response = Net::HTTP.start(loc_uri.hostname, loc_uri.port, use_ssl: true) { |http| http.request(loc_request) }
      loc_data = JSON.parse(loc_response.body)

      locations_list = loc_data["locations"] || []

      # Use first location if only one, or try to match by name
      matched = if locations_list.size == 1
        locations_list.first
      else
        locations_list.find { |l| l["title"]&.downcase&.include?(location.name.downcase) }
      end

      if matched
        location.update!(
          google_account_id: account_name.split("/").last,
          google_location_id: matched["name"].split("/").last
        )
        return
      end
    end

    # If no match found, store first account at least
    if accounts.any?
      location.update!(google_account_id: accounts.first["name"].split("/").last)
    end
  rescue => e
    Rails.logger.warn "Could not fetch Google Business IDs: #{e.message}"
  end
end

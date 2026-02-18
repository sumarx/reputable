require "net/http"
require "json"

module Replies
  class GoogleBusinessPoster
    attr_reader :review, :reply_text, :error

    def initialize(review, reply_text)
      @review = review
      @location = review.location
      @reply_text = reply_text
      @error = nil
    end

    def call
      unless @location.google_connected?
        @error = "Location is not connected to Google Business"
        return false
      end

      if @location.google_account_id.blank? || @location.google_location_id.blank?
        @error = "Missing Google account or location ID"
        return false
      end

      if review.external_review_id.blank?
        @error = "Review has no external Google ID"
        return false
      end

      ensure_valid_token!
      post_reply!
    rescue StandardError => e
      Rails.logger.error "GoogleBusinessPoster error for review #{review.id}: #{e.message}"
      @error = e.message
      false
    end

    private

    def post_reply!
      url = "https://mybusiness.googleapis.com/v4/accounts/#{@location.google_account_id}/locations/#{@location.google_location_id}/reviews/#{review.external_review_id}/reply"
      uri = URI(url)

      request = Net::HTTP::Put.new(uri, "Content-Type" => "application/json")
      request["Authorization"] = "Bearer #{@location.google_oauth_token}"
      request.body = { comment: reply_text }.to_json

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

      if response.is_a?(Net::HTTPSuccess)
        true
      else
        @error = "Google API returned #{response.code}: #{response.body}"
        Rails.logger.error "GoogleBusinessPoster API error: #{@error}"
        false
      end
    end

    def ensure_valid_token!
      return if @location.google_oauth_expires_at.present? && @location.google_oauth_expires_at > Time.current + 1.minute
      refresh_access_token!
    end

    def refresh_access_token!
      uri = URI("https://oauth2.googleapis.com/token")
      response = Net::HTTP.post_form(uri, {
        client_id: ENV["GOOGLE_OAUTH_CLIENT_ID"],
        client_secret: ENV["GOOGLE_OAUTH_CLIENT_SECRET"],
        refresh_token: @location.google_oauth_refresh_token,
        grant_type: "refresh_token"
      })
      data = JSON.parse(response.body)

      if data["error"]
        raise "Token refresh failed: #{data["error_description"] || data["error"]}"
      end

      @location.update!(
        google_oauth_token: data["access_token"],
        google_oauth_expires_at: Time.current + data["expires_in"].to_i.seconds
      )
    end
  end
end

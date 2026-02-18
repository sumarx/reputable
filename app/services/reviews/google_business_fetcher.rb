require "net/http"
require "json"

module Reviews
  class GoogleBusinessFetcher
    def initialize(location)
      @location = location
      @account = location.account
    end

    def call
      return error_result("Location not connected to Google Business") unless @location.google_connected?
      return error_result("Missing Google account or location ID") if @location.google_account_id.blank? || @location.google_location_id.blank?

      ensure_valid_token!
      fetch_all_reviews
    rescue StandardError => e
      Rails.logger.error "GoogleBusinessFetcher error for location #{@location.id}: #{e.message}"
      error_result(e.message)
    end

    private

    def fetch_all_reviews
      created = 0
      skipped = 0
      total = 0
      page_token = nil

      loop do
        url = "https://mybusiness.googleapis.com/v4/accounts/#{@location.google_account_id}/locations/#{@location.google_location_id}/reviews"
        url += "?pageToken=#{page_token}" if page_token

        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{@location.google_oauth_token}"

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

        unless response.is_a?(Net::HTTPSuccess)
          return error_result("API returned #{response.code}: #{response.body}")
        end

        data = JSON.parse(response.body)
        reviews = data["reviews"] || []
        total += reviews.size

        ActsAsTenant.with_tenant(@account) do
          reviews.each do |review_data|
            if import_review(review_data) == :created
              created += 1
            else
              skipped += 1
            end
          end
        end

        page_token = data["nextPageToken"]
        break if page_token.blank?
      end

      { success: true, created: created, skipped: skipped, total: total }
    end

    def import_review(review_data)
      external_id = review_data["reviewId"] || review_data["name"]&.split("/")&.last
      return :skipped if external_id.blank?

      existing = @location.reviews.find_by(platform: "google", external_review_id: external_id)
      if existing
        # Update reply if Google has one and we don't
        owner_reply = review_data.dig("reviewReply", "comment")
        if owner_reply.present? && existing.reply.blank?
          replied_at = review_data.dig("reviewReply", "updateTime").present? ? Time.parse(review_data.dig("reviewReply", "updateTime")) : Time.current
          existing.update!(reply: owner_reply, reply_status: "sent", replied_at: replied_at)
        end
        return :skipped
      end

      author_name = review_data.dig("reviewer", "displayName") || "Anonymous"
      rating = review_data["starRating"]
      rating_value = case rating
        when "ONE" then 1
        when "TWO" then 2
        when "THREE" then 3
        when "FOUR" then 4
        when "FIVE" then 5
        else nil
      end
      body = review_data["comment"] || ""
      published_at = review_data["createTime"].present? ? Time.parse(review_data["createTime"]) : Time.current

      # Check if owner already replied on Google
      owner_reply = review_data.dig("reviewReply", "comment")
      has_reply = owner_reply.present?

      @location.reviews.create!(
        account: @account,
        platform: "google",
        external_review_id: external_id,
        reviewer_name: author_name,
        rating: rating_value,
        body: body,
        published_at: published_at,
        reply_status: has_reply ? "sent" : "pending",
        reply: has_reply ? owner_reply : nil,
        replied_at: has_reply ? (review_data.dig("reviewReply", "updateTime").present? ? Time.parse(review_data.dig("reviewReply", "updateTime")) : published_at) : nil
      )

      :created
    end

    def ensure_valid_token!
      return if @location.google_oauth_expires_at.present? && @location.google_oauth_expires_at > Time.current + 1.minute
      refresh_access_token!(@location)
    end

    def refresh_access_token!(location)
      uri = URI("https://oauth2.googleapis.com/token")
      response = Net::HTTP.post_form(uri, {
        client_id: ENV["GOOGLE_OAUTH_CLIENT_ID"],
        client_secret: ENV["GOOGLE_OAUTH_CLIENT_SECRET"],
        refresh_token: location.google_oauth_refresh_token,
        grant_type: "refresh_token"
      })
      data = JSON.parse(response.body)

      if data["error"]
        raise "Token refresh failed: #{data["error_description"] || data["error"]}"
      end

      location.update!(
        google_oauth_token: data["access_token"],
        google_oauth_expires_at: Time.current + data["expires_in"].to_i.seconds
      )
    end

    def error_result(message)
      { success: false, error: message, created: 0, skipped: 0 }
    end
  end
end

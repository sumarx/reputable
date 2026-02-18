require "net/http"
require "json"
require "digest"

module Reviews
  class GooglePlacesFetcher
    def initialize(location)
      @location = location
      @account = location.account
    end

    def call
      return error_result("No google_place_id for location #{@location.id}") if @location.google_place_id.blank?

      api_key = ENV["GOOGLE_PLACES_API_KEY"]
      if api_key.blank?
        Rails.logger.warn "GOOGLE_PLACES_API_KEY not set — skipping Google reviews sync"
        return error_result("GOOGLE_PLACES_API_KEY not configured")
      end

      fetch_and_import(api_key)
    rescue StandardError => e
      Rails.logger.error "GooglePlacesFetcher error for location #{@location.id}: #{e.message}"
      error_result(e.message)
    end

    private

    def fetch_and_import(api_key)
      uri = URI("https://places.googleapis.com/v1/places/#{@location.google_place_id}")
      request = Net::HTTP::Get.new(uri)
      request["X-Goog-Api-Key"] = api_key
      request["X-Goog-FieldMask"] = "reviews"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        return error_result("API returned #{response.code}: #{response.body}")
      end

      data = JSON.parse(response.body)
      reviews = data["reviews"] || []

      created = 0
      skipped = 0

      ActsAsTenant.with_tenant(@account) do
        reviews.each do |review_data|
          result = import_review(review_data)
          if result == :created
            created += 1
          else
            skipped += 1
          end
        end
      end

      { success: true, created: created, skipped: skipped, total: reviews.size }
    end

    def import_review(review_data)
      author_name = review_data.dig("authorAttribution", "displayName") || "Anonymous"
      publish_time = review_data["publishTime"]
      external_id = Digest::SHA256.hexdigest("#{author_name}:#{publish_time}")[0..63]

      existing = @location.reviews.find_by(platform: "google", external_review_id: external_id)
      return :skipped if existing

      body = review_data.dig("originalText", "text") || review_data.dig("text", "text") || ""
      rating = review_data["rating"]
      published_at = publish_time.present? ? Time.parse(publish_time) : Time.current

      @location.reviews.create!(
        account: @account,
        platform: "google",
        external_review_id: external_id,
        reviewer_name: author_name,
        rating: rating,
        body: body,
        published_at: published_at,
        reply_status: "pending"
      )

      :created
    end

    def error_result(message)
      { success: false, error: message, created: 0, skipped: 0 }
    end
  end
end

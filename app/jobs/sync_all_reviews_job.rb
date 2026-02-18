class SyncAllReviewsJob < ApplicationJob
  queue_as :default

  def perform
    Location.where.not(google_place_id: [nil, ""]).find_each do |location|
      ActsAsTenant.with_tenant(location.account) do
        Reviews::GooglePlacesFetcher.new(location).call
      end
    rescue => e
      Rails.logger.error "SyncAllReviewsJob: Failed for location #{location.id}: #{e.message}"
    end
  end
end

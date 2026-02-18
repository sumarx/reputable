class SyncReviewsJob < ApplicationJob
  queue_as :default

  def perform(location)
    return unless location.is_a?(Location)

    ActsAsTenant.with_tenant(location.account) do
      if location.google_connected?
        result = Reviews::GoogleBusinessFetcher.new(location).call
        Rails.logger.info "Google Business sync for location #{location.id}: #{result.inspect}"
      elsif location.google_place_id.present?
        result = Reviews::GooglePlacesFetcher.new(location).call
        Rails.logger.info "Google Places sync for location #{location.id}: #{result.inspect}"
      else
        Rails.logger.info "No Google source configured for location #{location.id}, skipping"
      end
    end
  rescue => error
    Rails.logger.error "SyncReviewsJob failed for location #{location.id}: #{error.message}"
    raise error
  end
end

class SyncReviewsJob < ApplicationJob
  queue_as :default

  def perform(platform_connection)
    return unless platform_connection.is_a?(PlatformConnection)

    # Set the tenant for multi-tenancy
    ActsAsTenant.with_tenant(platform_connection.location.account) do
      Rails.logger.info "Starting review sync for #{platform_connection.platform} connection #{platform_connection.id}"

      case platform_connection.platform
      when 'google'
        sync_google_reviews(platform_connection)
      when 'facebook'
        sync_facebook_reviews(platform_connection)
      when 'tripadvisor'
        sync_tripadvisor_reviews(platform_connection)
      when 'yelp'
        sync_yelp_reviews(platform_connection)
      end

      platform_connection.update!(last_synced_at: Time.current)
    end
  rescue => error
    Rails.logger.error "SyncReviewsJob failed for connection #{platform_connection.id}: #{error.message}"
    platform_connection.update!(status: 'error')
    raise error
  end

  private

  def sync_google_reviews(connection)
    # TODO: Implement Google My Business API integration
    Rails.logger.info "Google reviews sync - placeholder implementation"
  end

  def sync_facebook_reviews(connection)
    # TODO: Implement Facebook Graph API integration
    Rails.logger.info "Facebook reviews sync - placeholder implementation"
  end

  def sync_tripadvisor_reviews(connection)
    # TODO: Implement TripAdvisor API integration
    Rails.logger.info "TripAdvisor reviews sync - placeholder implementation"
  end

  def sync_yelp_reviews(connection)
    # TODO: Implement Yelp API integration
    Rails.logger.info "Yelp reviews sync - placeholder implementation"
  end
end
# SEO & OG tag defaults — update REPUTABLE_DOMAIN when moving to production domain
Rails.application.config.x.seo = ActiveSupport::OrderedOptions.new.tap do |seo|
  seo.domain = ENV.fetch("REPUTABLE_DOMAIN", "sumarx.sajjadumar.dev")
  seo.site_name = "RepuTable"
  seo.default_title = "RepuTable — AI-Powered Restaurant Review & Reputation Manager"
  seo.default_description = "Turn every review into revenue. RepuTable helps restaurants monitor reviews across Google, Facebook & TripAdvisor, analyze sentiment with AI, generate smart replies, and collect more 5-star reviews with QR campaigns."
  seo.default_image = "/og-image.png"
  seo.twitter_handle = "@repikiirable"
  seo.theme_color = "#4f46e5"
end

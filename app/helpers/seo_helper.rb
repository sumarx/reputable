module SeoHelper
  def seo_config
    Rails.application.config.x.seo
  end

  def page_title(title = nil)
    if title.present?
      "#{title} | #{seo_config.site_name}"
    else
      content_for(:seo_title) || seo_config.default_title
    end
  end

  def page_description
    content_for(:seo_description) || seo_config.default_description
  end

  def page_image
    image = content_for(:seo_image) || seo_config.default_image
    if image.start_with?("http")
      image
    else
      "https://#{seo_config.domain}#{image}"
    end
  end

  def canonical_url
    content_for(:canonical_url) || request.original_url.split("?").first
  end

  def seo_meta_tags
    capture do
      # Basic meta
      concat tag.meta(name: "description", content: page_description)
      concat tag.meta(name: "robots", content: content_for(:robots) || "index, follow")
      concat tag.link(rel: "canonical", href: canonical_url)

      # Open Graph
      concat tag.meta(property: "og:type", content: content_for(:og_type) || "website")
      concat tag.meta(property: "og:site_name", content: seo_config.site_name)
      concat tag.meta(property: "og:title", content: page_title)
      concat tag.meta(property: "og:description", content: page_description)
      concat tag.meta(property: "og:image", content: page_image)
      concat tag.meta(property: "og:url", content: canonical_url)
      concat tag.meta(property: "og:locale", content: "en_US")

      # Twitter Card
      concat tag.meta(name: "twitter:card", content: "summary_large_image")
      concat tag.meta(name: "twitter:title", content: page_title)
      concat tag.meta(name: "twitter:description", content: page_description)
      concat tag.meta(name: "twitter:image", content: page_image)

      # Theme & PWA
      concat tag.meta(name: "theme-color", content: seo_config.theme_color)
      concat tag.meta(name: "application-name", content: seo_config.site_name)
      concat tag.meta(name: "apple-mobile-web-app-title", content: seo_config.site_name)
      concat tag.meta(name: "apple-mobile-web-app-capable", content: "yes")
      concat tag.meta(name: "apple-mobile-web-app-status-bar-style", content: "default")
    end
  end

  # JSON-LD structured data for the landing page
  def organization_schema
    {
      "@context" => "https://schema.org",
      "@type" => "SoftwareApplication",
      "name" => "RepuTable",
      "applicationCategory" => "BusinessApplication",
      "operatingSystem" => "Web",
      "description" => seo_config.default_description,
      "url" => "https://#{seo_config.domain}",
      "offers" => {
        "@type" => "AggregateOffer",
        "priceCurrency" => "USD",
        "lowPrice" => "0",
        "highPrice" => "199",
        "offerCount" => "3"
      },
      "provider" => {
        "@type" => "Organization",
        "name" => "RepuTable",
        "url" => "https://#{seo_config.domain}"
      }
    }
  end
end

require "net/http"
require "json"

module Notifications
  class SlackNotifier
    def self.send(webhook_url, message)
      return unless webhook_url.present?

      uri = URI(webhook_url)
      Net::HTTP.post(uri, { text: message }.to_json, "Content-Type" => "application/json")
    rescue => e
      Rails.logger.error("Slack notification failed: #{e.message}")
    end
  end
end

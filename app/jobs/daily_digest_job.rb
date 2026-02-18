class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    Account.find_each do |account|
      account.users.each do |user|
        next unless user.notification_settings&.email_daily_digest?

        ReviewMailer.daily_digest(account, user).deliver_later
      end
    end
  end
end

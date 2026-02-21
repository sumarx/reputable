class GenerateDashboardSummaryJob < ApplicationJob
  queue_as :default

  def perform(account_id, period = "30d")
    account = Account.find(account_id)

    ActsAsTenant.with_tenant(account) do
      stats = Dashboard::StatsService.new(account, period: period)
      Dashboard::AiSummaryService.new(account, stats).generate_and_store!
    end

    Rails.logger.info "Dashboard summary generated for account #{account_id}, period: #{period}"
  rescue => e
    Rails.logger.error "GenerateDashboardSummaryJob failed: #{e.message}"
    raise e
  end
end

module Billing
  module Enforceable
    extend ActiveSupport::Concern

    included do
      before_action :check_billing_status, unless: :billing_exempt?
    end

    private

    def check_billing_status
      return unless Current.account&.billing_locked?

      # Allow access to billing pages when account is locked
      return if billing_exempt?

      redirect_to billing_overview_path, 
        alert: "Your account has been suspended due to payment issues. Please update your billing to continue."
    end

    def billing_exempt?
      # Allow access to billing pages and essential account functions
      self.class.name.starts_with?('Billing::') ||
      (controller_name == 'sessions' && action_name == 'destroy') ||
      (controller_name == 'settings' && action_name.in?(['show', 'update']))
    end
  end
end
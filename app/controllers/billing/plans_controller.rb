module Billing
  class PlansController < ApplicationController
    before_action :resume_session

    def index
      @plans = Plan.where(active: true).order(:position)
      @current_subscription = Current.account.subscription
      @current_plan = @current_subscription&.plan
    end
  end
end

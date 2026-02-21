module LocationFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_location
    helper_method :current_location
  end

  private

  def set_current_location
    # Explicit param overrides session
    if params.key?(:location_id)
      if params[:location_id].present?
        session[:current_location_id] = params[:location_id]
      else
        session.delete(:current_location_id)
      end
    end

    @current_location = if session[:current_location_id].present?
      Current.account&.locations&.find_by(id: session[:current_location_id])
    end
  end

  def current_location
    @current_location
  end
end

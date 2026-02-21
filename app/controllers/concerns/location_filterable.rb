module LocationFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_location
  end

  private

  def set_current_location
    if params[:location_id].present?
      @current_location = Current.account&.locations&.find_by(id: params[:location_id])
    end
  end
end

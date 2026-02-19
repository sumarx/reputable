class ApplicationController < ActionController::Base
  include Authentication
  include Billing::Enforceable
  
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_tenant
  
  private
  
  def set_current_tenant
    ActsAsTenant.current_tenant = Current.account if Current.user
  end
end

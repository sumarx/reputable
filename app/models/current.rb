class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account
  
  delegate :user, to: :session, allow_nil: true
  
  def account
    return super if super.present?
    
    user&.account
  end
end

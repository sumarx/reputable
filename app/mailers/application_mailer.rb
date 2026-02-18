class ApplicationMailer < ActionMailer::Base
  default from: "RepuTable <#{ENV.fetch('SUMARX_GMAIL_USER', 'noreply@sajjadumar.dev')}>"
  layout "mailer"
end

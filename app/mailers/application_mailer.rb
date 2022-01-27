class ApplicationMailer < ActionMailer::Base
  default from: 'welcome@ecounsel.com <welcome@ecounsel.com>'
  layout 'mailer'
end

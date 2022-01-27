Twilio.configure do |config|
  config.account_sid = APP_CONFIG['TWILIO_ACCOUNT_SID']
  config.auth_token = APP_CONFIG['TWILIO_AUTH_TOKEN']
end
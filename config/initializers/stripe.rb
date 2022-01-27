Rails.configuration.stripe = {
  :publishable_key => APP_CONFIG['PUBLISHABLE_KEY'],
  :secret_key      => APP_CONFIG['SECRET_KEY']
}

Stripe.api_key = APP_CONFIG['SECRET_KEY']
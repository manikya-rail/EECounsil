class ZoomIntegration < ApplicationRecord

  def self.get_refresh_token
    auth_token = Base64.strict_encode64("#{APP_CONFIG['ZOOM_OAUTH_CLIENT_ID']}:#{APP_CONFIG['ZOOM_OAUTH_CLIENT_SECRET']}")
    refresh_token = ZoomIntegration.where(config_name: 'ZOOM_OAUTH_REFRESH_TOKEN').first.value
    uri = URI.parse("https://zoom.us/oauth/token?grant_type=refresh_token&refresh_token=#{refresh_token}")
    headers = {'Authorization': 'Basic ' + auth_token }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri, headers)
    res = http.request(req)
    access_token = JSON.parse(res.body)['access_token']
    refresh_token = JSON.parse(res.body)['refresh_token']
    self.where(config_name: 'ZOOM_OAUTH_ACCESS_TOKEN').first.update!(value: access_token) if access_token.present?
    self.where(config_name: 'ZOOM_OAUTH_REFRESH_TOKEN').first.update!(value: refresh_token) if refresh_token.present?
    Rails.logger.info "----------------Refresh token OP:------------------#{res.body} ---------------------------------------"
    access_token
  end

end

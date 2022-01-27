CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: APP_CONFIG["AWS_ACCESS_KEY"],
    aws_secret_access_key: APP_CONFIG["AWS_SECRET_KEY"],
    region: 'us-west-2',
    host: 's3-us-west-2.amazonaws.com',
    endpoint: 'https://s3-us-west-2.amazonaws.com'
  }
  config.fog_directory = 'ecounsel-profile-pictures'


  # case Rails.env
  #   when 'production'
  #     config.fog_directory = 'dummy'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/dummy'

  #   when 'development'
  #     config.fog_directory = 'dev.dummy'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/dev.dummy'

  #   when 'test'
  #     config.fog_directory = 'test.dummy'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/test.dummy'
  # end
end
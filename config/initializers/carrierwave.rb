if Rails.env.production?
  CarrierWave.configure do |config|
    config.aws_credentials = {
      access_key_id:     ENV['BAYT_KEY'],
      secret_access_key: ENV['BAYT_SECRET'],
      region:            'us-east-1',
      endpoint:          ENV['BAYT_URL']
    }

    config.asset_host = ENV['BAYT_ASSET_URL']
    config.aws_bucket = 'sandbox'
    config.aws_acl    = 'public-read'
  end
end

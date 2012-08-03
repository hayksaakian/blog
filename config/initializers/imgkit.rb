IMGKit.configure do |config|
  config.wkhtmltoimage = Rails.root.join('bin', 'wkhtmltoimage-amd64').to_s if Rails.env.production?
  config.wkhtmltoimage = '/usr/local/bin/wkhtmltoimage' if Rails.env.development?
	config.default_options = {
    :quality => 80
  }
  config.default_format = :png  
end
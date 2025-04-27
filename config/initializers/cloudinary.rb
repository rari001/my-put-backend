Cloudinary.config do |config|
  config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']  # Cloudinaryのcloud_name
  config.api_key = ENV['CLOUDINARY_API_KEY']      # CloudinaryのAPIキー
  config.api_secret = ENV['CLOUDINARY_API_SECRET'] # CloudinaryのAPIシークレット
  config.secure = true
end

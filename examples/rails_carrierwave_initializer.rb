BUCKET_NAME = "images"

if Rails.env.production?
  Anynines::Swift::Utility.configure_carrierwave(BUCKET_NAME)
end

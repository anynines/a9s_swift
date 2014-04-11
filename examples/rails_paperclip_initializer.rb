BUCKET_NAME = "images"

if Rails.env.production?
  Anynines::Swift::Utility.configure_paperclip(BUCKET_NAME)
end
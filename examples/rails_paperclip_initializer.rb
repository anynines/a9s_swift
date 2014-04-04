BUCKET_NAME = "images"

if Rails.env.production?
  require 'paperclip'
  require 'a9s_swift'
  Anynines::Swift::Utility.configure_paperclip(BUCKET_NAME)
end
require 'fog'
require 'a9s_swift'

BUCKET_NAME = "images"

if Rails.env.production?
  Anynines::Swift::Utility.configure_paperclip(BUCKET_NAME)
end

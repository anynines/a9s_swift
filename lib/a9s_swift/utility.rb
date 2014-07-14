require 'fog'
require 'json'

class Anynines::Swift::Utility
  SWIFT_HOST = "https://swift.hydranodes.de"

  # Returns a fog storage connection to the swift service
  # @return [Fog::Storage] a fog storage connection
  def self.fog_connection
    Fog::Storage.new fog_credentials_hash
  end

  # Sets up paperclip for the usage with the anynines service.
  # Creates a bucket with the given name if not already present.
  # @param image_bucket_name [String] the bucket name to use
  # @param options [Hash] a hash of additional options
  def self.configure_paperclip(image_bucket_name, options = {})
    raise "Paperclip wasn't found in your environment! Please verify that paperclip is included within your Gemfile and loaded correctly." if defined?(Paperclip).nil?

    opts = initialize_options options
    create_new_bucket(image_bucket_name, opts[:fog_public])

    # configure paperclip to use the credentials provided by the anynines environment    
    Paperclip::Attachment.default_options.update(
      {
        :path => ":class/:id/:attachment/:style/img_:fingerprint",
        :storage => :fog,
        :fog_credentials => self.fog_credentials_hash,
        :fog_directory => image_bucket_name,
        :fog_public => opts[:fog_public],
        :fog_host => "#{SWIFT_HOST}/v1/AUTH_#{fog_hash[:hp_tenant_id]}/#{image_bucket_name}"
      })
  end

  # Sets up carrierwave for the usage with the anynines service.
  # Creates a bucket with the given name if not already present.
  # @param image_bucket_name [String] the bucket name to use
  # @param options [Hash] a hash of additional options
  def self.configure_carrierwave(image_bucket_name, options = {})
    raise "CarrierWave wasn't found in your environment! Please verify that carrierwave is included within your Gemfile and loaded correctly." if defined?(CarrierWave).nil?

    opts = initialize_options options
    create_new_bucket(image_bucket_name, opts[:fog_public])

    CarrierWave.configure do |config|
      config.fog_credentials = fog_credentials_hash

      config.storage = :fog
      config.fog_directory  = image_bucket_name
      config.fog_public     = opts[:fog_public]                                   # optional, defaults to true
    end
  end

  # Returns a fog compatible credentials hash for the swift service
  def self.fog_credentials_hash
    # parse the VCAP_SERVICES environment variable
    services = JSON.parse(ENV["VCAP_SERVICES"])
    raise "Couldn't find the VCAP_SERVICE env variable! Are you running within an anynines environment?" if services.nil?
    raise "Couldn't access the a9s swift service credentials from env! Have you bound a swift service instance to the application?" if services["swift-1.0"].nil?
    swift_service = services["swift-1.0"].first

    return {
       :provider => 'HP',
       :hp_access_key => swift_service["credentials"]["user_name"],
       :hp_secret_key => swift_service["credentials"]["password"],
       :hp_tenant_id => swift_service["credentials"]["tenant_id"],
       :hp_auth_uri => swift_service["credentials"]["authentication_uri"],
       :hp_use_upass_auth_style => true,
       :hp_avl_zone => swift_service["credentials"]["availability_zone"],
       :os_account_meta_temp_url_key => swift_service["credentials"]["account_meta_key"]
    }
  end

  # Creates a new bucket with the given name if not already present
  # @param bucket_name [String] a name for the bucket
  # @param public_access [Boolean] should the bucket be publicly accessible?
  def self.create_new_bucket(bucket_name, public_access)
    connection = fog_connection
    if connection.directories.get(bucket_name).nil?
      puts "The bucket with key=#{bucket_name} wasn't found. Creating bucket with key=#{bucket_name} ."
      bucket = connection.directories.create key: bucket_name

      # set the directory to be public
      bucket.public = public_access
      bucket.save

      connection = nil
      return true
    else
      puts "The bucket with key=#{bucket_name} is already present! Skipping bucket creation."
      return false
    end
  end

  private

  def self.initialize_options(options)
    # set fog_public to true if not defined within the options
    options[:fog_public] = true if options[:fog_public].nil?
    return options
  end
end

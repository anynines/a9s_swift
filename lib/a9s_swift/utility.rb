require 'fog'
require 'json'

class Anynines::Swift::Utility
  SWIFT_HOST = "https://swift.hydranodes.de"

  # Returns a fog storage connection to the swift service
  # @return [Fog::Storage] a fog storage connection
  def self.fog_connection(provider = "hp")
    Fog::Storage.new fog_credentials_hash(provider)
  end

  # Sets up paperclip for the usage with the anynines service.
  # Creates a bucket with the given name if not already present.
  # @param image_bucket_name [String] the bucket name to use
  # @param options [Hash] a hash of additional options
  def self.configure_paperclip(image_bucket_name, options = {}, provider = "hp")
    raise "Paperclip wasn't found in your environment! Please verify that paperclip is included within your Gemfile and loaded correctly." if defined?(Paperclip).nil?

    opts = initialize_options options
    create_new_bucket(image_bucket_name, opts[:fog_public], provider)

    # configure paperclip to use the credentials provided by the anynines environment
    Paperclip::Attachment.default_options.update(
      {
        :path => ":class/:id/:attachment/:style/img_:fingerprint",
        :storage => :fog,
        :fog_credentials => self.fog_credentials_hash(provider),
        :fog_directory => image_bucket_name,
        :fog_public => opts[:fog_public],
        :fog_host => "#{SWIFT_HOST}/v1/AUTH_#{fog_hash[:hp_tenant_id]}/#{image_bucket_name}"
      })
  end

  # Sets up carrierwave for the usage with the anynines service.
  # Creates a bucket with the given name if not already present.
  # @param image_bucket_name [String] the bucket name to use
  # @param options [Hash] a hash of additional options
  # @param provider [String] 'hp' or 'openstack'
  def self.configure_carrierwave(image_bucket_name, options = {}, provider = "hp")
    raise "CarrierWave wasn't found in your environment! Please verify that carrierwave is included within your Gemfile and loaded correctly." if defined?(CarrierWave).nil?

    opts = initialize_options options
    create_new_bucket(image_bucket_name, opts[:fog_public], provider)

    CarrierWave.configure do |config|
      config.fog_credentials = fog_credentials_hash(provider)

      config.storage = :fog
      config.fog_directory  = image_bucket_name
      config.fog_public     = opts[:fog_public]                                   # optional, defaults to true
    end
  end

  # Returns a fog compatible credentials hash for the swift service
  # @param provider [String] 'hp' or 'openstack'
  def self.fog_credentials_hash(provider = "hp")
    provider = provider.downcase
    # parse the VCAP_SERVICES environment variable
    services = JSON.parse(ENV["VCAP_SERVICES"])
    raise "Couldn't find the VCAP_SERVICE env variable! Are you running within an anynines environment?" if services.nil?
    raise "Couldn't access the a9s swift service credentials from env! Have you bound a swift service instance to the application?" if services["swift-1.0"].nil?
    swift_service = services["swift-1.0"].first

    if provider == "hp"
      fog_credentials_hash_hp_provider swift_service
    elsif provider == "openstack"
      fog_credentials_hash_openstack_provider swift_service
    else
      raise "No recognized provider. Please use 'hp' or 'openstack' as provider choice."
    end
  end

  # Creates a new bucket with the given name if not already present
  # @param bucket_name [String] a name for the bucket
  # @param public_access [Boolean] should the bucket be publicly accessible?
  # @param provider [String] 'hp' or 'openstack'
  def self.create_new_bucket(bucket_name, public_access, provider = "hp")
    connection = fog_connection provider
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

  def self.fog_credentials_hash_openstack_provider(vcap_service_subhash)
    auth_uri = vcap_service_subhash["credentials"]["authentication_uri"]
    last_route = auth_uri[auth_uri.length - 6, auth_uri.length - 1]
    if last_route != "tokens"
      last_char = auth_uri[auth_uri.length - 1]
      if last_char == "/"
        auth_uri = "#{auth_uri}tokens"
      else
        auth_uri = "#{auth_uri}/tokens"
      end
    end

    {
       :provider => 'OpenStack',
       :openstack_auth_url => auth_uri,
       :openstack_username => vcap_service_subhash["credentials"]["user_name"],
       :openstack_api_key => vcap_service_subhash["credentials"]["password"],
       :openstack_temp_url_key => vcap_service_subhash["credentials"]["account_meta_key"]
    }
  end

  def self.fog_credentials_hash_hp_provider(vcap_service_subhash)
    {
       :provider => 'HP',
       :hp_access_key => vcap_service_subhash["credentials"]["user_name"],
       :hp_secret_key => vcap_service_subhash["credentials"]["password"],
       :hp_tenant_id => vcap_service_subhash["credentials"]["tenant_id"],
       :hp_auth_uri => vcap_service_subhash["credentials"]["authentication_uri"],
       :hp_use_upass_auth_style => true,
       :hp_avl_zone => vcap_service_subhash["credentials"]["availability_zone"],
       :os_account_meta_temp_url_key => vcap_service_subhash["credentials"]["account_meta_key"]
    }
  end
end

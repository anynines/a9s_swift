require 'fog'
require 'a9s_swift'

# ---- hp provider usage ----
# initialize a connection to Swift using the fog hp storage driver
con = Anynines::Swift::Utility.fog_connection('hp')

# display the generated fog configuration hash for the hp driver
puts Anynines::Swift::Utility.fog_credentials_hash('hp')

# create a public directory using the connection
con.directories.create(key: 'my_directory', public: true)

# list directories using the connection
puts con.directories


# ---- OpenStack provider usage ----
# initialize a connection to Swift using the fog openstack storage driver
con = Anynines::Swift::Utility.fog_connection('openstack')

# display the generated fog configuration hash for the openstack driver
puts Anynines::Swift::Utility.fog_credentials_hash('openstack')

# create a public directory using the connection
con.directories.create(key: 'my_directory2', public: true)

# list directories using the connection
puts con.directories

# list files within the directory
puts con.directories.first.files

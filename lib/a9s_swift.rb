module Anynines
  module Swift
    autoload :Utility, File.expand_path('../a9s_swift/utility', __FILE__)
  end
  
  def self.version
    file = File.open(File.expand_path("../../VERSION", __FILE__))
    return file.read.to_s.tr("\n","")
  end
end

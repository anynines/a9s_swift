= a9s_swift

a9s_swift is a small helper gem to ease up the usage of the anyines.com swift service within your applications.
It enables a one-line configuration of the following libraries:

* paperclip
* carrierwave
* fog

== Dependencies

* fog gem : https://github.com/fog/fog
* paperclip (optional: if you would like to use the paperclip configuration feature)
* carrierwave (optional: if you would like to use the carrierwave configuration feature)

== Installation
	gem install a9s_swift
	
	or
	
	gem 'a9s_swift' -> Gemfile
	bundle

== Usage

=== rails applications with carrierwave or paperclip

Some example initializers are provided in the examples directory. Just copy the according file over to your rails application's app/config/initializers directory and start using the anynines swift service within your live applications. 

Please make sure to bind a swift service instance to your application to enable access to the swift credentials.

=== fog
	con = Anynines::Swift::Utility.fog_connection # returns a fog connection to the a9s swift service 
	con.directories
	
=== paperclip configuration featue
	Anynines::Swift::Utility.configure_paperclip("image_bucket") # create bucket, configure paperclip with a9s swift service
	
=== carrierwave configuration feature
	Anynines::Swift::Utility.configure_carrierwave("image_bucket") # create bucket, configure carrierwave with a9s swift service
	

== Contributing to a9s_swift
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2014 Julian Weber. See LICENSE.txt for
further details.


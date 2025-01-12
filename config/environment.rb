# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'

# Rails Gem Version
RAILS_GEM_VERSION = '1.2.6' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/app/services )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  config.log_level = :warn

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

Inflector.inflections do |inflect|
  inflect.uncountable %w( status )
end

# Include your application configuration below

# Allow multiple Rails applications by giving the session cookie a
# unique prefix.

ActionController::Base.session_options[:session_key] = 'collaboaapp_session_id'

# Make ruby use utf8
$KCODE = 'u'

require 'jcode'
require 'syntax/lib/syntax'
Syntax::all().each { |syntax| Syntax::load(syntax) }
require 'syntax/lib/syntax/convertors/html'
require 'digest/sha1'
require 'redcloth'
#require 'redcloth/lib/redcloth'

# Where do we store our attachments?
ATTACHMENTS_PATH = RAILS_ROOT + '/attachments'

# Load our config file
REPOS_CONF = YAML::load(File.open("#{RAILS_ROOT}/config/repository.yml"))

# Require ActionSubversion
require 'actionsubversion/lib/action_subversion'
# Setup the path to our Subversion repository
ActionSubversion::Base.repository_path = REPOS_CONF[RAILS_ENV]['repos_path'].to_s

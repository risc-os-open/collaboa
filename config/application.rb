require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Collaboa
  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    #
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    #
    config.autoload_lib(ignore: %w(assets tasks))

    # Eager-load anything else in 'lib'.
    #
    config.eager_load_paths << Rails.root.join("lib")

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    # Set the path to our Subversion repository.
    #
    Rails::Application::Finisher.initializer 'org.riscosopen.collaboa.initializer' do
      ActionSubversion::Base.repository_path = REPOS_CONF[Rails.env]['repos_path'].to_s
    end

    # Add the shared ROOL view components.
    #
    shared_views_path = if ENV['SHARED_VIEWS_PATH'].blank?
      Rails.root.join('..', 'common', 'views')
    else
      ENV['SHARED_VIEWS_PATH']
    end
    config.paths['app/views'].unshift(shared_views_path)

    # If running in a deployed environment, allow requests to Epsilon. Send
    # e-mail via Beta, which is on the same local network.
    #
    if Socket.gethostname == 'epsilon'
      config.hosts << "epsilon.arachsys.com"

      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address:        'beta.arachsys.com',
        port:           25,
        domain:         'epsilon.arachsys.com',
        user_name:      nil,
        password:       nil,
        authentication: nil,
        enable_starttls_auto: true
      }
    end

  end
end

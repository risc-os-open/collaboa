source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 7.2"

# Use PostgresSQL
#
gem 'pg', '~> 1.5.8'

# Use the Puma web server [https://github.com/puma/puma]
#
gem "puma", ">= 5.0"

# Reduces boot times through caching; required in config/boot.rb
#
gem "bootsnap", require: false

# For Windows or esoteric Unix/Linux-like distributions.
#
gem 'tzinfo-data'

# Use SCSS for stylesheets via a robust preprocessing step:
# https://rubygems.org/gems/cssbundling-rails/
#
gem 'cssbundling-rails' # ...using whatever version Rails wants

# Use a robust preprocessing step for JavaScript, too; this lets us manage any
# components available in NPM that have both JS and CSS components using the
# same mechanism (Yarn):
# https://rubygems.org/gems/jsbundling-rails/
#
gem 'jsbundling-rails' # ...using whatever version Rails wants

# Rails 7+ 'modern' asset pipeline:
# https://rubygems.org/gems/propshaft
#
gem 'propshaft', '~> 1.1'

# Use Hub for authentication [https://github.com/pond/hubssolib]
#
gem 'hubssolib', '~> 2.0', require: 'hub_sso_lib'

# Easy pagination [https://rubygems.org/gems/pagy]
#
gem 'pagy', '~> 9.0'

# Replace Rails <= 3.0 'auto_link' [https://rubygems.org/gems/rails_autolink]
#
gem 'rails_autolink', '~> 1.1'

# List positioning [https://rubygems.org/gems/acts_as_list]
#
gem 'acts_as_list', '~> 1.2'

# Textile support [https://rubygems.org/gems/RedCloth]
#
gem 'RedCloth', '~> 4.3'

# Markdown with GFM extensions etc. [https://rubygems.org/gems/commonmarker]
#
gem 'commonmarker', '~> 1.1'

# Wider support for markup formats [https://rubygems.org/gems/github-markup]
#
gem 'github-markup', '~> 5.0'

# HTML processing [https://rubygems.org/gems/html-pipeline]
#
gem 'html-pipeline', '~> 3.2'

# Custom data structures (removed from Ruby core in 3.5.0)
# [https://rubygems.org/gems/ostruct]
#
gem 'ostruct', '~> 0.6'

group :development, :test do

  # Standard debugger
  #
  gem 'debug'

  # E-mail inspection.
  #
  gem 'mailcatcher'

end

group :development do

  # Use console on exceptions pages [https://github.com/rails/web-console]
  #
  gem 'web-console'

  # Be able to run 'bin/dev'
  gem "foreman"

end

group :test do
end

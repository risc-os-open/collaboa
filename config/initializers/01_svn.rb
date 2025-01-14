require_relative '../../lib/action_subversion/base'

ActionSubversion::Base.repository_path = REPOS_CONF[Rails.env]['repos_path'].to_s

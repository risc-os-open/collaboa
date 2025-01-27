# Code which used to be run on a schedule job as its Ruby and gem dependencies
# were far newer than the then-ancient Rails stack. With the Rails stack up to
# date and locked in as ROOL-specific forks, this code can move here and we
# don't need a scheduled job anymore. It can be run on demand (rate-limited).
#
require 'net/http'
require 'net/https'
require 'json'
require 'thread'
require 'ostruct'
require 'active_support/core_ext/string'

# Editable configuration.
#
module GitLabSupport
  JSON_OUTPUT_PATH    = Rails.root.join('tmp',    'gitlab_recent_events.json'                    ) # See .gitignore
  USERS_INCLUDED_PATH = Rails.root.join('config', 'gitlab_users_to_include_in_recent_events.json') # See .gitignore
  EVENTS_TO_INCLUDE   = 50

  INTERESTING_NAMESPACES = [
    'RiscOS/',
    'Products/',
    'Support/'
  ]

  INTERESTING_ACTION_NAMES =
  [
    'accepted',
    'pushed',
    'pushed to',
    'pushed new',
  ]

  INTERESTING_TARGET_TYPES =
  [
    nil,
    # for example... add 'MergeRequest'
  ]
end

require 'git_lab_support/git_lab_api_client.rb'
require 'git_lab_support/git_lab_recents.rb'

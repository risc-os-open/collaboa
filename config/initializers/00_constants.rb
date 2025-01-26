# Where do we store our attachments?
ATTACHMENTS_PATH = Rails.root.join('attachments').to_s

# Load our config file
REPOS_CONF = YAML::load(File.open(Rails.root.join('config', 'repository.yml').to_s))

# SVN support enabled?
SVN_ENABLED = false

# We support the old CVS viewer's hacked-in GitLab summary, hacking it in here
# instead! It uses JSON data exported from a uchedule job to a known location.
#
if ENV['SHARED_FILES_PATH'].blank?
  raise 'You must define SHARED_FILES_PATH so that GitLab JSON files can be located'
end

GITLAB_RECENT_EVENTS_JSON_LOCATION = File.join(ENV['SHARED_FILES_PATH'], 'data', 'gitlab_recent.json')

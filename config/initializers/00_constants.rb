# Where do we store our attachments?
ATTACHMENTS_PATH = Rails.root.join('attachments').to_s

# Load our config file
REPOS_CONF = YAML::load(File.open(Rails.root.join('config', 'repository.yml').to_s))

# SVN support enabled?
SVN_ENABLED = false


# ROOL UI flags - hide Release menus/info from the UI, as that's no longer
# relevant in a ROOL GitLab world?
HIDE_RELEASES = true

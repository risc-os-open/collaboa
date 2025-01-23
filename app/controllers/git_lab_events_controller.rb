# A special case controller for ROOL which uses a pre-parsed JSON dump of
# recent "interesting" events in GitLab and provides a list.
#
# This is available as both an HTML view and an RSS feed on an "index" only.
#
class GitLabEventsController < ApplicationController

  @@last_file_datetime = nil
  @@event_data         = nil

  def index
    last_file_datetime = File.mtime(GITLAB_JSON_LOCATION)

    if (@@last_file_datetime.nil? || last_file_datetime > @@last_file_datetime)
      @@event_data         = JSON.parse(File.read(GITLAB_JSON_LOCATION))
      @@last_file_datetime = last_file_datetime
    end

    @title  = 'Events'
    @events = @@event_data
  end

end

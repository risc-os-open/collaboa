# A special case controller for ROOL which uses a pre-parsed JSON dump of
# recent "interesting" events in GitLab and provides a list.
#
# This is available as both an HTML view and an RSS feed on an "index" only.
#
class GitLabEventsController < ApplicationController

  REGENERATE_RECENTS_EVERY = 1.hour
  @@regeneration_mutex     = Mutex.new
  @@event_data             = nil

  def index
    regenerate_recents_json = true

    @@regeneration_mutex.synchronize do

      # First level of sort-of-caching: Only call GitLab at most as often as
      # defined by REGENERATE_RECENTS_EVERY.
      #
      if File.exist?(GitLabSupport::JSON_OUTPUT_PATH)
        current_file_datetime = File.mtime(GitLabSupport::JSON_OUTPUT_PATH)
        file_age_in_seconds   = Time.now - current_file_datetime

        regenerate_recents_json = false if file_age_in_seconds < REGENERATE_RECENTS_EVERY
      end

      # This can take a while!
      #
      if regenerate_recents_json
        GitLabSupport::GitLabRecents.retrieve_latest()
      end
    end

    # Second level of sort-of-caching: Only parse the JSON file if it has been
    # updated, or if we haven't cached it in a previous request (this only
    # working in Production environments, of course, where a single controller
    # instance can live across multiple requests).
    #
    if @event_data.nil? || regenerate_recents_json
      @@event_data = JSON.parse(File.read(GitLabSupport::JSON_OUTPUT_PATH))
    end

    @title  = 'Events'
    @events = @@event_data

    respond_to do | format |
      format.html { render }
      format.any(*XML_LIKE_FORMATS) { render(formats: [:xml]) }
    end
  end

end

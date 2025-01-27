xml.instruct!
xml.feed(xmlns: "http://www.w3.org/2005/Atom", 'xml:lang': 'en') do
  xml.id(git_lab_events_url(format: request.format))
  xml.title('ROOL GitLab events')
  xml.updated(File.mtime(GitLabSupport::JSON_OUTPUT_PATH).utc.iso8601(3))
  xml.link(rel: 'self', href: git_lab_events_url(format: request.format))

  @events.each_with_index do | event, event_index |
    event_time  = (Time.parse(event['date']).utc rescue Time.now.utc)
    event_title = "#{event['action'].capitalize} #{event['target_prefix']} #{event['target']} in #{event['project']} (#{event['author']}) - #{event['summary']}"

    xml.entry do | entry |
      entry.id("tag:riscosopen.org,#{event_time.to_date.iso8601}:#{event_index}")
      entry.title(event_title)
      entry.updated(event_time.iso8601(3))
      entry.author do | author |
        author.name(event['author'])
      end
      entry.link(rel: 'alternate', type: 'text/html', href: event['action_url'])
      entry.content(event_title, type: 'text')
    end
  end
end

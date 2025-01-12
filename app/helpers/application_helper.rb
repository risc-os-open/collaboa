# The methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  include WhiteListFormattedContentConcern

  def make_links(text)
    text.gsub!(/changeset\s#?([0-9]+)/i){|s| link_to("Changeset ##{$1}", :controller => 'repository', :action => 'show_changeset', :revision => $1)}
    text.gsub!(/ticket\s#?([0-9]+)/i){|s| link_to("Ticket ##{$1}", :controller => 'tickets', :action => 'show', :id => $1)}
    return text
  end

  def htmlize(text)
    return if text.nil?
    html = xhtml_sanitize(html, auto_link: true, textile: true) # See WhiteListFormattedContentConcern
    make_links(html)
    return html.html_safe()
  end
end

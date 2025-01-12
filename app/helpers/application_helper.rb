# The methods added to this helper will be available to all templates in the application.

class Object::Array
  def cycle()
    self.each_with_index {|o, i| yield(o, %w(odd even)[i % 2])}
  end
end

module ApplicationHelper
  def make_links(text)
    text.gsub!(/changeset\s#?([0-9]+)/i){|s| link_to("Changeset ##{$1}", :controller => 'repository', :action => 'show_changeset', :revision => $1)}
    text.gsub!(/ticket\s#?([0-9]+)/i){|s| link_to("Ticket ##{$1}", :controller => 'tickets', :action => 'show', :id => $1)}
    return text
  end

  def format_and_make_links(text)
    text = make_links(text)
    text = simple_format(text)
    return text
  end

  def htmlize(text)
    return if text.nil?
    text.gsub!("<", "&lt;")
    text.gsub!(">", "&gt;")
    text = auto_link( text ) { |visible| truncate(visible, 50) }
    text = RedCloth.new(text).to_html
    make_links(text)
    return text
  end

  def request
    @request
  end
end

module ApplicationHelper
  include WhiteListFormattedContentConcern
  include Pagy::Frontend

  # Turn the Hub and Rails flash data into a simple series of H2 entries,
  # with Hub data first, Rails flash data next. A container DIV will hold
  # zero or more H2 entries:
  #
  #   <div class="flash">
  #     <h2 class="flash foo">Bar</h2>
  #   </div>
  #
  # ...where "foo" is the flash key, e.g. "alert", "notice" and "Bar" is
  # the flash value, made HTML-safe.
  #
  def apphelp_flash
    data = hubssolib_flash_data()
    html = ""

    return tag.div( :class => 'flash' ) do
      data[ 'hub' ].each do | key, value |
        concat( tag.h2( value, class: "flash #{ key }" ) )
      end

      data[ 'standard' ].each do | key, value |
        concat( tag.h2( value, class: "flash #{ key }" ) )
      end
    end
  end

  # https://gist.github.com/mattyoho/1113828
  #
  def error_messages_for(*objects)
    options = objects.extract_options!

    options[:header_message] ||= 'Problems with form submission'
    options[:message       ] ||= 'Please correct the following errors and try again.'

    messages = objects.compact.map { |o| o.errors.full_messages }.flatten

    unless messages.empty?
      content_tag(:div, class: 'error_messages') do
        list_items = messages.map { |msg| content_tag(:li, msg) }

        content_tag(:h2, options[:header_message]   ) +
        content_tag(:p,  options[:message       ]   ) +
        content_tag(:ul, list_items.join.html_safe())
      end
    end
  end

  def make_links(text)
    text.gsub!(/changeset\s#?([0-9]+)/i){|s| link_to("Changeset ##{$1}", :controller => 'repository', :action => 'show_changeset', :revision => $1)}
    text.gsub!(/ticket\s#?([0-9]+)/i){|s| link_to("Ticket ##{$1}", :controller => 'tickets', :action => 'show', :id => $1)}
    return text
  end

  def htmlize(text)
    return if text.nil?
    html = xhtml_sanitize(text, auto_link: true, textile: true) # See WhiteListFormattedContentConcern
    make_links(html)
    return html.html_safe()
  end

  # For things where markup isn't guaranteed, so no Textile, but do all the
  # other whitelisting and processing.
  #
  def simple_htmlize(text)
    return if text.nil?
    html = xhtml_sanitize(text, auto_link: true, textile: false) # See WhiteListFormattedContentConcern
    make_links(html)
    return html.html_safe()
  end
end

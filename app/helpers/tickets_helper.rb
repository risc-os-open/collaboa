module TicketsHelper
  def tickethelp_format_author(address)
    if address =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
      mail_to(address, address)
    else
      address
    end
  end

  def tickethelp_format_changes(change_arr)
    changed = change_arr[0]
    ch_from = change_arr[1]
    ch_to   = change_arr[2]
    html    = "<strong>#{h(changed)}</strong> changed from <em>#{h(ch_from)}</em> to <em>#{h(ch_to)}</em>".html_safe()

    if HIDE_RELEASES && changed&.downcase == 'release'
      html << ' <small>(releases are historic, relevant to CVS source control only)</small>'.html_safe()
    end

    return html
  end

  # Returns 'true' if anything other than the *default* "status 1" set is in
  # use.
  #
  def tickethelp_filters_active?
    Ticket::PERMITTED_FILTER_FIELDS.any? do | field |
      params[field].present? && (field != 'status' || params[field] != '1')
    end
  end

  def link_to_add_filter(object)
    # Note we omit :page here intentionally, so that new filters start on page 1
    safe_params = params.permit(:sort_key, :sort_order, *Ticket::PERMITTED_FILTER_FIELDS)
    obj_name    = object.class.to_s.downcase

    add_params = safe_params.merge({obj_name => object.id.to_s}).each{|p| p}
    # Reject the current filter
    del_params = safe_params.reject{ |key, value| value == object.id.to_s && key == obj_name}

    text_link, short_link = if safe_params == add_params
      [link_to(tag.strong(object.name), del_params), link_to('-', del_params)]
    else
      [link_to(object.name, add_params), link_to('+', add_params)]
    end

    return "#{text_link} [#{short_link}]".html_safe
  end

  def render_next_prev_links
    out = %{<div class="ticket-next-prev">}
    out << "<p><small>"
    if @ticket.previous
      out << link_to('Previous', :action => 'show', :id => @ticket.previous)
    end
    if @ticket.next
      out << '&nbsp;|&nbsp;' if @ticket.previous
      out << link_to('Next', :action => 'show', :id => @ticket.next)
    end
    out << "</small></p>\n</div>"
    out.html_safe()
  end

end

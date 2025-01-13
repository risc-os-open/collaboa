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

    "<strong>#{h(changed)}</strong> changed from <em>#{h(ch_from)}</em> to <em>#{h(ch_to)}</em>".html_safe()
  end

  def link_to_add_filter(object)
    good_things = %w{milestone part severity release status}
    obj_name = object.class.to_s.downcase

    add_params = params.merge({obj_name => object.id.to_s}).each{|p| p}
    # Reject the current filter
    del_params = params.reject{ |key, value|  value == object.id.to_s && key == obj_name}

    out = '['
    unless params == add_params
      out << link_to('+', add_params)
    else
      out << link_to('-', del_params)
    end
    out << ']'
  end

  def render_next_prev_links
    out = %{<div class="ticket-next-prev">}
    out << "<p><small>"
    if @ticket.previous
      out << link_to('Previous', :action => 'show', :id => @ticket.previous)
    end
    if @ticket.next
      out << '|' if @ticket.previous
      out << link_to('Next', :action => 'show', :id => @ticket.next)
    end
    out << "</small></p>\n</div>"
    out.html_safe()
  end

end

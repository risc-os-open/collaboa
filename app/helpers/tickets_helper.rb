module TicketsHelper
  def format_author(address)
    if address =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
      mail_to(address, address, :encode => "javascript")
    else
      address
    end
  end

  def format_changes(change_arr)
    "<strong>#{change_arr[0]}</strong> changed from <em>#{change_arr[1]}</em> to <em>#{change_arr[2]}</em>"
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
    out
  end

end

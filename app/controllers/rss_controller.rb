class RssController < ApplicationController
  before_filter :set_xml_header, :except => [ :index ]

  def index
    render :layout => 'application'
  end
  
  def all
    @rss_title = 'ROOL Tracker'
    @items = []
    
    Ticket.find_all(nil, 'created_at DESC', 5).each do |ticket|
      @items << {:title => "Ticket ##{ticket.id} created: " + ticket.summary,
                :content => ticket.content,
                :author => ticket.author,
                :date => ticket.created_at,
                :link => "tickets/show/#{ticket.id}"}
    end
    
    TicketChange.find_all(nil, 'created_at DESC', 5).each do |change|
      content = ''
      unless change.comment.empty?
        content << "<p>#{change.comment}</p>\n"
      end
      change.each_log {|logitem| content << '<ul>' + format_changes(logitem) + '</ul' }

      @items << {:title => "Ticket ##{change.ticket_id} modified by #{change.author}",
                :content => content,
                :author => change.author,
                :date => change.created_at,
                :link => "tickets/show/#{change.ticket_id}"}
    end
    
    Changeset.find_all(nil, 'created_at DESC', 5).each do |changeset|
      @items << {:title => "Changeset #{changeset.revision} by #{changeset.author}",
                :content => changeset.log,
                :author => changeset.author,
                :date => changeset.revised_at,
                :link => "repository/changesets/#{changeset.revision}"}
    end
    render :action => 'rss'    
  end
  
  def tickets
    @rss_title = 'ROOL Tracker: All tickets'
    @items = []

    Ticket.find_all(nil, 'created_at DESC', 5).each do |ticket|
      @items << {:title => "Ticket ##{ticket.id} created: " + ticket.summary,
                :content => ticket.content,
                :author => ticket.author,
                :date => ticket.created_at,
                :link => "tickets/show/#{ticket.id}"}
    end

    TicketChange.find_all(nil, 'created_at DESC', 5).each do |change|
      content = ''
      unless change.comment.empty?
        content << "<p>#{change.comment}</p>\n"
      end
      change.each_log {|logitem| content << '<ul>' + format_changes(logitem) + '</ul>' }

      @items << {:title => "Ticket ##{change.ticket_id} modified by #{change.author}",
                :content => content,
                :author => change.author,
                :date => change.created_at,
                :link => "tickets/show/#{change.ticket_id}"}
    end
    render :action => 'rss'
  end

  def ticket_creation
    @rss_title = 'ROOL Tracker: Ticket creation'
    @items = []

    Ticket.find_all(nil, 'created_at DESC', 5).each do |ticket|
      @items << {:title => "Ticket ##{ticket.id} created: " + ticket.summary,
                :content => ticket.content,
                :author => ticket.author,
                :date => ticket.created_at,
                :link => "tickets/show/#{ticket.id}"}
    end
    render :action => 'rss'
  end

  def ticket_changes
    @rss_title = 'ROOL Tracker: Ticket changes'
    @items = []

    TicketChange.find_all(nil, 'created_at DESC', 5).each do |change|
      content = ''
      unless change.comment.empty?
        content << "<p>#{change.comment}</p>\n"
      end
      change.each_log {|logitem| content << '<ul>' + format_changes(logitem) + '</ul>' }

      @items << {:title => "Ticket ##{change.ticket_id} modified by #{change.author}",
                :content => content,
                :author => change.author,
                :date => change.created_at,
                :link => "tickets/show/#{change.ticket_id}"}
    end
    render :action => 'rss'
  end

  def changesets
    @rss_title = 'ROOL Tracker: Changesets'
    @items = []
    Changeset.find_all(nil, 'created_at DESC', 15).each do |changeset|
      @items << {:title => "Changeset #{changeset.revision} by #{changeset.author}",
                :content => changeset.log,
                :author => changeset.author,
                :date => changeset.revised_at,
                :link => "repository/changesets/#{changeset.revision}"}
    end
    render :action => 'rss'
  end
  
  private
    def format_changes(change_arr)
      "<li><strong>#{change_arr[0]}</strong> changed from <em>#{change_arr[1]}</em> to <em>#{change_arr[2]}</em></li>"
    end
    
    def set_xml_header
      headers["Content-Type"] = "text/xml; charset=utf-8"
    end

end

class RssController < ApplicationController
  include TicketsHelper

  def index
    render()
  end

  def all
    @rss_title = 'ROOL Tracker'
    @items     = []

    add_recent_tickets_to!(@items)
    add_recent_ticket_changes_to!(@items)
    add_recent_changesets_to!(@items)

    render action: 'rss'
  end

  def tickets
    @rss_title = 'ROOL Tracker: All tickets'
    @items     = []

    add_recent_tickets_to!(@items)
    add_recent_ticket_changes_to!(@items)

    render action: 'rss'
  end

  def ticket_creation
    @rss_title = 'ROOL Tracker: Ticket creation'
    @items     = []

    add_recent_tickets_to!(@items)

    render action: 'rss'
  end

  def ticket_changes
    @rss_title = 'ROOL Tracker: Ticket changes'
    @items     = []

    add_recent_ticket_changes_to!(@items)

    render action: 'rss'
  end

  def changesets
    @rss_title = 'ROOL Tracker: Changesets'
    @items     = []

    add_recent_changesets_to!(@items)

    render action: 'rss'
  end

  # ============================================================================
  # PRIVATE INSTANCE METHODS
  # ============================================================================
  #
  private

    def add_recent_tickets_to!(items)
      Ticket.all.order('created_at DESC').limit(5).each do |ticket|
        items << {
          title:   "Ticket ##{ticket.id} created: " + ticket.summary,
          content: ticket.content,
          author:  ticket.author,
          date:    ticket.created_at,
          link:    ticket_path(ticket)
        }
      end
    end

    def add_recent_ticket_changes_to!(items)
      TicketChange.all.order('created_at DESC').limit(5).each do |change|
        content = ''
        content << "<div>#{htmlize(change.comment)}</div>\n" if change.comment.present?

        content << '<ul>'
        change.each_log do |logitem|
          content << '<li>' + tickethelp_format_changes(logitem) + '</li>'
        end
        content << '</ul>'

        items << {
          title:   "Ticket ##{change.ticket_id} modified by #{change.author}",
          content: content.html_safe(),
          author:  change.author,
          date:    change.created_at,
          link:    ticket_path(change.ticket_id)
        }
      end
    end

    def add_recent_changesets_to!(items)
      Changeset.all.order('created_at DESC').limit(5).each do |changeset|
        items << {
          title:   "Changeset #{changeset.revision} by #{changeset.author}",
          content: changeset.log,
          author:  changeset.author,
          date:    changeset.revised_at,
          link:    repository_show_changeset_path(revision: changeset.revision)
        }
      end
    end

end

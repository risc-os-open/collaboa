# Some smaller tweaks has been made to this helper.

# Helpers to sort tables using clickable column headers.
#
# Author: Stuart Rackham <srackham@methods.co.nz>, March 2005.
#
# - Consecutive clicks toggle the column's sort order.
# - Sort state is maintained by a session hash entry.
# - Icon image identifies sort column and state.
# - Typically used in conjunction with the Pagination module.
#
# Example code snippets:
#
# Controller:
#
#   helper :sort
#   include SortHelper
#
#   def list
#     sort_init('last_name')
#     sort_update()
#     @items = Contact.order(sort_clause())
#   end
#
# Controller (using Pagination module):
#
#   helper :sort
#   include SortHelper
#
#   def list
#     sort_init 'last_name'
#     sort_update
#     @contact_pages, @contacts = pagy_with_params(scope: ...order(sort_clause())...)
#   end
#
# View (table header in list.rhtml):
#
#   <thead>
#     <tr>
#       <%= sort_header_tag('id', :title => 'Sort by contact ID') %>
#       <%= sort_header_tag('last_name', :caption => 'Name') %>
#       <%= sort_header_tag('phone') %>
#       <%= sort_header_tag('address', :width => 200) %>
#     </tr>
#   </thead>
#
# - The ascending and descending sort icon images are sort_asc.png and
#   sort_desc.png and reside in the application's images directory.
# - Introduces instance variables: @sort_name, @sort_default.
# - Introduces params :sort_key and :sort_order.
#
module SortHelper

  # Initializes the default sort column (default_key) and sort order
  # (default_order).
  #
  # - default_key is a column attribute name.
  # - default_order is 'asc' or 'desc'.
  # - name is the name of the session hash entry that stores the sort state,
  #   defaults to '<controller_name>_sort'.
  #
  def sort_init(default_key, default_order='asc', name=nil)
    @sort_name = name || params[:controller] + '_sort'
    @sort_default = {:key => default_key, :order => default_order}
  end

  # Updates the sort state. Call this in the controller prior to calling
  # sort_clause.
  #
  def sort_update()
    if params[:sort_key]
      sort = {key: params[:sort_key], order: params[:sort_order]}
    elsif session[@sort_name]
      sort = session[@sort_name]   # Previous sort.
    else
      sort = @sort_default
    end
    session[@sort_name] = sort
  end

  # Returns an SQL sort clause corresponding to the current sort state.
  # Use this to sort the controller's table items collection. Pass the Hash
  # to an #order call in an ActiveRecord::Relation chain.
  #
  def sort_clause()
    key   = self.get_sort_key()
    order = self.get_sort_order()

    # The input comes from the URL, so might be malicious.
    #
    # https://api.rubyonrails.org/v7.1/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_for_order
    #
    # This does not appear to work and I can produce no meaningful results from
    # it. It wraps things in single quotes breaking them for ORDER statements,
    # or passes things through unchanged; it does not seem intended for this
    # use case.
    #
    # This would have been noticed sooner, probably, except for something lower
    # in Rails that throws an exception the minute it sees something bad in an
    # "order" statement *even without ever compiling and running the query*. It
    # throws ActiveRecord::UnknownAttributeReference. There are other ways in
    # which a bad sort will produce other errors (e.g. PG::UndefinedColumn, at
    # the point where the view is rendering) so we just let that all throw as a
    # 500 error if it happens.
    #
    return {key => order}
  end

  # Returns a link which sorts by the named column.
  #
  # - column is the name of an attribute in the sorted record collection.
  # - The optional caption explicitly specifies the displayed link text.
  # - A sort icon image is positioned to the right of the sort link.
  #
  def sort_link(column, caption=nil)
    key   = self.get_sort_key()
    order = self.get_sort_order()

    if key == column
      if order.downcase == 'asc'
        icon = 'sort_asc'
        order = 'desc'
      else
        icon = 'sort_desc'
        order = 'asc'
      end
    else
      icon = nil
      order = 'asc'
    end

    caption = column.humanize.titleize unless caption
    params[:sort_key] = column
    params[:sort_order] = order
    #link_to(caption, params) + (icon ? nbsp(2) + image_tag(icon) : '')
    css_order_class = icon ? order : ''
    link_to(caption, params.to_unsafe_h, { :class => css_order_class })
  end

  # Returns a table header <th> tag with a sort link for the named column
  # attribute.
  #
  # Options:
  #   :caption     The displayed link name (defaults to titleized column name).
  #   :title       The tag's 'title' attribute (defaults to 'Sort by :caption').
  #
  # Other options hash entries generate additional table header tag attributes.
  #
  # Example:
  #
  #   <%= sort_header_tag('id', :title => 'Sort by contact ID', :width => 40) %>
  #
  # Renders:
  #
  #   <th title="Sort by contact ID" width="40">
  #     <a href="/contact/list?sort_order=desc&amp;sort_key=id">Id</a>
  #     &nbsp;&nbsp;<img alt="Sort_asc" src="/images/sort_asc.png" />
  #   </th>
  #
  def sort_header_tag(column, options = {})
    if options[:caption]
      caption = options[:caption]
      options.delete(:caption)
    else
      caption = column.humanize.titleize
    end
    options[:title]= "Sort by #{caption}" unless options[:title]
    tag.th(sort_link(column, caption), **options)
  end

  private

    # The ID fallback is a result of some tables not having 'created_at' and a
    # wider, historic assumption of monotonically rising ID integers. This is
    # OK for us at the moment, since that is indeed what our data layer uses.
    # For someone with e.g. UUIDs, though, the sort order would be nonsensical
    # (but this is only a just-in-chance fallback).
    #
    def get_sort_key
      session.dig(@sort_name, 'key'  ) || session.dig(@sort_name, :key  ) || 'id'
    end

    def get_sort_order
      session.dig(@sort_name, 'order') || session.dig(@sort_name, :order) || 'desc'
    end

end

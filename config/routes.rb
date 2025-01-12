ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.connect '/admin', :controller => 'admin/dashboard', :action => 'index'

  map.connect '/repository/browse/*path',
              :controller => 'repository',
              :action => 'browse'

  # "Routing Error: Path components must occur last" :(
  #map.connect '/repository/browse/*path/rev/:rev',
  #            :controller => 'repository',
  #            :action => 'browse',
  #            :rev => /\d+/

  # TODO: Rework this into a general browse/view_file usable thing
  #map.connect '/repository/file/rev/:rev/*path',
  #            :controller => 'repository',
  #            :action => 'view_file',
  #            :rev => /\d+/

  map.connect '/repository/file/*path',
              :controller => 'repository',
              :action => 'view_file'

  map.connect '/repository/revisions/*path',
              :controller => 'repository',
              :action => 'revisions'

  map.connect '/repository/changesets',
              :controller => 'repository',
              :action => 'changesets'

  map.connect '/repository/changesets/:revision',
              :controller => 'repository',
              :action => 'show_changeset'

  map.connect '/tickets',
              :controller => 'tickets',
              :action => 'index'

  map.connect '/tickets/new',
              :controller => 'tickets',
              :action => 'new'

  map.connect '/tickets/:id',
              :controller => 'tickets',
              :action => 'show',
              :requirements => { :id => /\d+/ }

  map.connect '/milestones',
              :controller => 'milestones',
              :action => 'index'

  map.connect '/milestones/:id',
              :controller => 'milestones',
              :action => 'show'

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '/',
              :controller => 'tickets'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect '/:controller/:action/:id'
end

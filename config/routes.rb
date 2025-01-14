Rails.application.routes.draw do
  root to: 'tickets#index'

  namespace 'admin' do
    root to: 'dashboard#index'

    # "New" views are inline in the index; "Show" is handled via the public UI,
    # with no need for a special case in the admin UI.
    #
    resources :milestones, except: [:new, :show]
    resources :parts,      except: [:new, :show]
    resources :releases,   except: [:new, :show]
    resources :users,      except: [:new, :show]
  end

  match '/login',  to: 'login#login', via: [:get, :post]
  get   '/logout', to: 'login#logout'

  resources :milestones, only: [:index, :show]

  get '/repository',                            to: redirect('repository/browse')
  get '/repository/browse/(*path)',             to: 'repository#browse'
  get '/repository/file/*path',                 to: 'repository#view_file'
  get '/repository/send_data_to_browser/*path', to: 'repository#send_data_to_browser'
  get '/repository/revisions/(*path)',          to: 'repository#revisions'
  get '/repository/changesets',                 to: 'repository#changesets'
  get '/repository/changesets/:revision',       to: 'repository#show_changeset', as: 'repository_show_changeset'

  get '/rss',                 to: 'rss#index'
  get '/rss/all',             to: 'rss#all'
  get '/rss/changesets',      to: 'rss#changesets'
  get '/rss/tickets',         to: 'rss#tickets'
  get '/rss/ticket_creation', to: 'rss#ticket_creation'
  get '/rss/ticket_changes',  to: 'rss#ticket_changes'

  get        'tickets/filter',         to: 'tickets#filter'
  get        'tickets/attachment/:id', to: 'tickets#attachment'
  match      'tickets/comment/:id',    to: 'tickets#comment', via: [:get, :post]
  resources :tickets, only: [:index, :new, :create, :show]

  get '/search', to: 'search#index'
end

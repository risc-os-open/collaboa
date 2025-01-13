Rails.application.routes.draw do
  root to: 'tickets#index'

  namespace 'admin' do
    root to: 'dashboard#index'

    resources :milestones, except: :show
    resources :parts,      except: :show
    resources :releases,   except: :show
    resources :users,      except: :show
  end

  post '/login',  to: 'login#login'
  get  '/logout', to: 'login#logout'

  resources :milestones, only: [:index, :show]

  get '/repository',                            to: redirect('repository#browse')
  get '/repository/browse/*path',               to: 'repository#browse'
  get '/repository/file/*path',                 to: 'repository#view_file'
  get '/repository/send_data_to_browser/*path', to: 'repository#send_data_to_browser'
  get '/repository/revisions/*path',            to: 'repository#revisions'
  get '/repository/changesets',                 to: 'repository#changesets'
  get '/repository/changesets/:revision',       to: 'repository#show_changeset', as: 'repository_show_changeset'

  get '/rss/all',             to: 'rss#all'
  get '/rss/changesets',      to: 'rss#changesets'
  get '/rss/tickets',         to: 'rss#tickets'
  get '/rss/ticket_creation', to: 'rss#ticket_creation'
  get '/rss/ticket_changes',  to: 'rss#ticket_changes'

  resources :tickets, only: [:index, :new, :create, :show]
  get  'tickets/filter',  to: 'tickets#filter'
  get  'tickets/comment', to: 'tickets#comment'
  post 'tickets/comment', to: 'tickets#comment'
end

Rails.application.routes.draw do
  resources :materiels
  get '/materiels/traces/(:id)', to: 'materiels#index_trace', as: 'materiels_traces'
  resources :traces, :randonnees, :treks
  get '/randonnees/page/(:id)', to: 'randonnees#index', as: 'randonnees_page'
  get '/randonnees/trek/(:idtrek)/page/(:idpage)', to: 'randonnees#trek_index', as: 'randonnees_trek_page'
  get '/treks/page/(:id)', to: 'treks#index', as: 'treks_page'
  post 'uploadimage', to: 'admin#upload_image'
  get '/admin', to: 'admin#password'
  get '/apropos', to: 'treks#a_propos'
  get '/agenda', to: 'admin#agenda'
  post '/admin', to: 'admin#check_password'
  root to: 'application#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

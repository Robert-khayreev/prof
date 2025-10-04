Rails.application.routes.draw do
  root "home#index"
  
  # Authentication routes
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  resources :profiles do
    member do
      get :analytics
    end
  end
  
  scope :spectator, as: :spectator do
    get 'index', to: 'spectator#index'
    get 'show/:id', to: 'spectator#show', as: :show
    post 'track/:id', to: 'spectator#track', as: :track
    post 'reset', to: 'spectator#reset'
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end

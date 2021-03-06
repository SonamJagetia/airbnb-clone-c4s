Rails.application.routes.draw do
  root 'pages#home'

  devise_for :users, 
              path: '',
              path_names: {sign_in: 'login', sign_out: 'logout', edit: 'profile', sign_up: 'registration'},
              controllers: {omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations'}
              
  resources :users, only: [:show] do 
    member do
      post '/verify_phone_number', to: 'users#verify_phone_number'
      patch '/update_phone_number', to: 'users#update_phone_number'
    end
  end
  
  resources :rooms, except: [:edit] do
    member do 
      get 'listing'
      get 'pricing'
      get 'description'
      get 'photo_upload'
      get 'amenities'
      get 'location'
      get 'preload'
      get 'preview'
    end
    resources :photos, only: [:create, :destroy]
    resources :reservations, only: [:create]
    resources :calendars
  end
  
  resources :guest_reviews, only: [:create, :destroy]
  resources :host_reviews, only: [:create, :destroy]
  
  get '/your_trips', to: 'reservations#your_trips'
  get '/your_reservations', to: 'reservations#your_reservations'
  
  get 'search', to: 'pages#search'
  
  # ----- Airkong -----
  get 'dashboard', to: 'dashboards#index'
  
  resources :reservations, only: [:approve, :decline] do
    member do
      post '/approve', to: "reservations#approve"
      post '/decline', to: "reservations#decline"
    end
  end
  
  resources :revenues, only: [:index]
  
  resources :conversations, only: [:index, :create] do 
    resources :messages, only: [:index, :create]
  end
  
  get '/host_calendar', to: "calendars#host"
  get '/payment_method', to: "users#payment"
  get '/payout_method', to: "users#payout"
  post '/add_card', to: "users#add_card"
  
  get '/notification_settings', to: "settings#edit"
  post '/notification_settings', to: "settings#update"
  
  get '/notifications', to: 'notifications#index'
  
  mount ActionCable.server => '/cable'
  
  
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      get '/logout', to: 'users#logout'
      post '/facebook', to: 'users#facebook'
      post '/payments', to: 'users#add_card'
      get '/listings', to: 'rooms#your_listings'
      
      resources :rooms do
        member do
          get '/reservations', to: 'reservations#reservations_by_room'
        end
      end
      resources :reservations do
        member do
          post '/approve', to: 'reservations#approve'
          post '/decline', to: 'reservations#decline'
        end
      end
    end
  end
  
end

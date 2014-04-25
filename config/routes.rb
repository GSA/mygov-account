require 'api_constraints'

Mygov::Application.routes.draw do
  mount_roboto

  devise_for :users, :path => '', :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks',
    :registrations => 'users/registrations',
    :confirmations => 'users/confirmations',
    :sessions => 'users/sessions',
    :unlocks => 'users/unlocks',
    :passwords => 'users/passwords'
  }
  devise_scope :user do
    get 'sign_up', :to => 'users/registrations#new', :as => :sign_up
    get 'thank_you', :to => 'users/registrations#thank_you', :as => :thank_you
    get 'sign_in', :to => 'users/sessions#new', :as => :sign_in
    get 'sign_out', :to => 'users/sessions#destroy', :as => :sign_out
    get 'active'  => 'users/sessions#active',  via: :get
    get 'timeout' => 'users/sessions#timeout', via: :get
  end
  get 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/allow' => 'oauth#allow'
  get 'oauth/unknown_app' => 'oauth#unknown_app', :as => :unknown_app
  resources :beta_signups, :only => [:create]
  #resource :user, :only => [:destroy]
  resource :user, only: [:edit, :destroy] do
    collection do
      get 'edit_password'
      put 'update_password'
      get 'edit_notification_settings'
      put 'update_notification_settings'
    end
  end
  resources :account, :only => [:index] do
    collection do
      resources :authentications
    end
  end
  resource :profile, :only => [:show, :edit, :update]
  resources :notifications, :only => [:index, :show, :create, :destroy]
  resources :tasks, :only => [:index, :show, :update, :destroy]
  resources :apps do
    member do
      get :uninstall
      get :leaving
    end
  end
  resources :task_items, :only => [:update, :destroy]
  get 'dashboard' => "home#dashboard"
  get 'developer' => "home#developer"
  get 'privacy-policy' => "home#privacy_policy", :as => :privacy_policy
  get 'terms-of-service' => "home#terms_of_service", :as => :terms_of_service
  get 'about' => "home#about", :as => :about
  get 'paperwork-reduction-act-statement' => "home#pra", :as => :pra
  get 'xrds' => "home#xrds", :as => :xrds

  namespace :api, :defaults => {:format => :json} do
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 1, :default => true) do
      resource :profile, :only => [:show]
      resources :notifications, :only => [:create]
      resources :tasks, :only => [:index, :create, :show, :update]
      resources :forms, :only => [:create, :show]
      get "credentials/verify" => "credentials#verify", :as => :verify_credentials
    end
  end
  match "/404", :to => "errors#not_found"
  rack_error_handler = ActionDispatch::PublicExceptions.new('public/')
  match "/422" => rack_error_handler
  match "/500" => rack_error_handler
  match "/api/*path" => "application#xss_options_request", :via => :options

  root :to => 'home#index'
end

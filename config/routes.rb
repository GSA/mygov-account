Mygov::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => 'users/registrations', :confirmations => 'users/confirmations' }
  devise_scope :user do
    get 'sign_up', :to => 'users/registrations#new', :as => :sign_up
    get 'thank_you', :to => 'users/registrations#thank_you', :as => :thank_you
    get 'sign_in', :to => 'devise/sessions#new', :as => :sign_in
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :sign_out
  end
  resources :oauth_apps
  get 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/authorize' => 'oauth#authorize'
  post 'oauth/allow' => 'oauth#allow'
  resource :profile, :controller => :users, :only => [:show, :edit, :update, :destroy]
  resources :messages, :only => [:index, :show, :create, :destroy]
  get 'dashboard' => "home#dashboard"
  resources :tasks, :only => [:show, :update, :destroy]
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  resources :apps, :only => [:show] do
    member do
      post :start
      post :info
      post :address
      post :birthdate
      post :contact_info
      get :review
      post :review
      get :forms
      post :forms
      get :save
      get :finish
    end
  end
  resources :task_items, :only => [:update, :destroy]
  get '/pdfs/fill', :to => 'pdfs#fill'
  resources :beta_signups, :only => [:create]
  match '/welcome', :to => 'welcome#index', :as => :welcome
  match  'terms-of-service', :controller => 'home', :action => 'render_page', :page => 'terms-of-service', :as => 'terms_of_service'
  match  'privacy-policy', :controller => 'home', :action => 'render_page', :page => 'privacy-policy', :as => 'privacy_policy'
  
  namespace :api do
    resource :profile, :only => [:show]
    resources :notifications, :only => [:create]
    resources :tasks, :only => [:index, :create, :show]
  end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

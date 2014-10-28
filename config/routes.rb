Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  
  # auto-login links
  get '/al/:id' => 'users#auto_login', :as => :auto_login
  
  match "/rooms/product_search" => "boards#product_search", :as => :board_product_search, :via =>[:get, :post]
  get "/rooms/search" => "boards#search", :as => :board_search
  get "/rooms/gettaxons" => "boards#gettaxons", :as => :board_gettaxons

  resources :board_products
  resources :color_collections do 
    resources :colors
  end
  resources :rooms, controller: 'boards'  do 
    resources :board_products
    resources :color_matches
  end
  resources :designer_registrations
  
  
  
  get "/tutorials" => "designers#tutorials", :as => :tutorials
  get "/designers" => "designers#index", :as => :designers
  get "/designers/thanks" => "designer_registrations#thanks", :as => :designer_registration_thanks
  get "/designers/signup" => "designer_registrations#new", :as => :designer_signup
  patch "/designers" => "designers#update", :as => :update_designer
  #post "/designers/signup" => "designers#signup", :as => :create_designer_registration
  
  get "/mission" => "extra#mission" , :as => :mission
  
  get "/home" => "boards#home", :as => :home
  post "/orders/add_to_cart" => "orders#add_to_cart", :as => :orders_add_to_cart
  
  # designer dashboard links
  get "/dashboard" => "boards#dashboard", :as => :designer_dashboard
  get "/my_profile" => "boards#profile", :as => :my_profile
  get "/my_rooms" => "boards#my_rooms", :as => :my_rooms
  resources :bookmarks
  post "/bookmarks/remove" => "bookmarks#destroy", :as => :remove_bookmark
  get "/our_suppliers" => "extra#our_suppliers", :as => :our_suppliers
  get "/tips_tricks" => "extra#tips_tricks", :tips_tricks => :tips_tricks
  get "/video_tutorial" => "extra#video_tutorial", :as => :video_tutorial

  # room builder links
  get '/rooms/build/:id' => "boards#build", :as => :build_board
  get '/rooms/:id/design' => "boards#design", :as => :design_board
  get '/rooms/:id/preview' => "boards#preview", :as => :preview_board
  get '/colors/get_color/:swatch_val' => "colors#get_color", :as => :get_color_by_swatch
  get '/products/:id/product_with_variants' => "products#product_with_variants", :as => :product_with_variants
  
  get '/widget/room/:id' => "widget#room", :as => :room_widget

  #post '/registration_subscribers' => 'user_registrations#registration_subscribers', :as => :registration_subscribers
  devise_scope :spree_user do
    post '/registration_subscribers' => 'user_registrations#registration_subscribers', :as => :registration_subscribers
    #, :constraints => { :protocol => "https"}
  end
  resources :subscribers, :only => [:new, :create] do
    collection do
      post :login_or_create
      post :login_user
    end
  end
  
  #get "/boards/product_search" => "boards#product_search", :as => :board_product_search
   
 
  namespace :admin do
    
    
    
    #match "/board_products", to: "board_products#update", via: :put
    match "/board_products/mark_approved", to: "board_products#mark_approved", via: :post
    match "/board_products/mark_rejected", to: "board_products#mark_rejected", via: :post
    
    match "/boards/approval_form", to: "boards#approval_form", via: :get
    match "/boards/revision_form", to: "boards#revision_form", via: :get
    
    match "/boards/approve", to: "boards#approve", via: :post
    match "/boards/request_revision", to: "boards#request_revision", via: :post

    
    get  "boards/list" => "boards#list", :as => :boards_list
    match  "boards/products(/:status)" => "boards#products", :as => :boards_products, :via =>[:get, :post]
    resources :boards
    resources :board_products
    resources :designer_registrations
    resources :slides
    
    get  "designers" => "users#designers", :as => :designers
    
    # Product Import Tables
    get  "product_import" => "product_import#index", :as => :product_import
    post "product_import" => "product_import#upload", :as => :post_product_import

    resources :import_tables
    resources :import_logs

    post 'import_tables/:id' => 'import_tables#merge', :as => :create_products_from_csv    
    get 'import_tables/:id/results' => 'import_tables#results', as: :import_table_results
    get 'import_tables/:id/percent_complete' => 'import_tables#completion', as: :import_table_completion
  end

end

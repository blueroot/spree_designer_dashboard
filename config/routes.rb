Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :board_products

  get '/al/:id' => 'users#auto_login', :as => :auto_login
  resources :color_collections do 
    resources :colors
  end
  
  match "/rooms/product_search" => "boards#product_search", :as => :board_product_search, :via =>[:get, :post]
  
  get "/rooms/search" => "boards#search", :as => :board_search
  get "/tutorials" => "designers#tutorials", :as => :tutorials
  resources :rooms, controller: 'boards'  do 
    resources :board_products
    resources :color_matches
  end
  resources :designer_registrations
  resources :bookmarks
  post "/bookmarks/remove" => "bookmarks#destroy", :as => :remove_bookmark
  
  get "/designers/thanks" => "designer_registrations#thanks", :as => :designer_registration_thanks
  
  get "/designers/signup" => "designer_registrations#new", :as => :designer_signup
  #post "/designers/signup" => "designers#signup", :as => :create_designer_registration
  
  get "/dashboard" => "home#dashboard", :as => :designer_dashboard
   get "/mission" => "home#mission" , :as => :mission
  get "/home" => "boards#home", :as => :home
  post "/orders/add_to_cart" => "orders#add_to_cart", :as => :orders_add_to_cart
  get "/my_profile" => "home#profile", :as => :my_profile
  patch "/designers" => "designers#update", :as => :update_designer
  get "/my_rooms" => "boards#my_rooms", :as => :my_rooms

  get "/designers" => "designers#index", :as => :designers
  
  
  get "/our_suppliers" => "extra#our_suppliers", :as => :our_suppliers
  get "/tips_tricks" => "extra#tips_tricks", :tips_tricks => :tips_tricks
  get "/video_tutorial" => "extra#video_tutorial", :as => :video_tutorial

  get '/rooms/build/:id' => "boards#build", :as => :build_board
  get '/rooms/:id/design' => "boards#design", :as => :design_board
  get '/rooms/:id/preview' => "boards#preview", :as => :preview_board

  get '/widget/room/:id' => "widget#room", :as => :room_widget
  
  
  #get "/boards/product_search" => "boards#product_search", :as => :board_product_search
   
 
  namespace :admin do
    match "/board_products", to: "board_products#update", via: :put
    resources :boards
    resources :board_products
    resources :designer_registrations
    
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

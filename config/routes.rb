Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  
  
  match "/rooms/product_search" => "boards#product_search", :as => :board_product_search, :via =>[:get, :post]
  
  get "/rooms/search" => "boards#search", :as => :board_search
  resources :rooms, controller: 'boards'  do 
    resources :board_products
    resources :color_matches
  end
  resources :designer_registrations
  
  get "/designers/thanks" => "designer_registrations#thanks", :as => :designer_registration_thanks
  
  get "/designers/signup" => "designer_registrations#new", :as => :designer_signup
  #post "/designers/signup" => "designers#signup", :as => :create_designer_registration
  
  get "/dashboard" => "home#dashboard", :as => :designer_dashboard
  post "/orders/add_to_cart" => "orders#add_to_cart", :as => :orders_add_to_cart
  get "/my_profile" => "home#profile", :as => :my_profile
  patch "/designers" => "designers#update", :as => :update_designer
  get "/my_rooms" => "boards#my_rooms", :as => :my_rooms

  get "/designers" => "designers#index", :as => :designers
  get "/designer/:id" => "designers#show", :as => :designer

  get '/rooms/build/:id' => "boards#build", :as => :build_board
  get '/rooms/:id/design' => "boards#design", :as => :design_board
  
  
  #get "/boards/product_search" => "boards#product_search", :as => :board_product_search
  
  
  
  
  
  resources :board_products
  
  
  namespace :admin do
    resources :boards
    resources :board_products
    resources :designer_registrations
  end

end

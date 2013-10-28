Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  
  resources :boards do 
    resources :board_products
  end
  resources :designer_registrations
  
  get "/designers/thanks" => "designer_registrations#thanks", :as => :designer_registration_thanks
  
  get "/designers/signup" => "designer_registrations#new", :as => :designer_signup
  #post "/designers/signup" => "designers#signup", :as => :create_designer_registration
  
  get "/dashboard" => "home#dashboard", :as => :designer_dashboard
  post "/orders/add_to_cart" => "orders#add_to_cart", :as => :orders_add_to_cart
  get "/my_profile" => "home#profile", :as => :my_profile
  get "/my_boards" => "boards#my_boards", :as => :my_boards
  #get "/designers" => "designers#index", :as => :designers
  
  get '/boards/build/:id' => "boards#build", :as => :build_board
  get '/boards/:id/design' => "boards#design", :as => :design_board
  post "/boards/product_search" => "boards#product_search", :as => :board_product_search
  get "/boards/search" => "boards#search", :as => :board_search
  #get "/designer/:id" => "designers#show", :as => :designer
  
  
  
  
  resources :board_products
  
  
  namespace :admin do
    resources :boards
    resources :board_products
    resources :designer_registrations
  end

end

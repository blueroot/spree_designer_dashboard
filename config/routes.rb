Spree::Core::Engine.routes.prepend do
  # Add your extension routes here
  
  get "/dashboard" => "home#dashboard"
  get "/my_profile" => "home#profile"
  get "/my_boards" => "boards#my_boards"
  match "/boards/product_search" => "boards#product_search"
  
  match '/boards/build/:id' => "boards#build", :as => :build_board
  resources :boards do 
    resources :board_products
  end
  resources :board_products
  
  
  namespace :admin do
    resources :boards
    resources :board_products
  end
end

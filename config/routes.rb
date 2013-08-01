Spree::Core::Engine.routes.prepend do
  # Add your extension routes here
  
  get "/dashboard" => "home#dashboard"
  get "/my_profile" => "home#profile"
  get "/my_boards" => "boards#my_boards"
  
  match '/boards/build/:id' => "boards#build", :as => :build_board
  resources :boards
  
  
  namespace :admin do
    resources :boards
  end
end

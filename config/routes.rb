Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "admin/products#index"

  namespace :admin do
    resources :categories
    resources :products
  end
  get "/dashboard" => "dashboard#index"
end

NewDart::Application.routes.draw do
  resources :courses

  resources :departments

  devise_for :users

  root to: "home#index"
end

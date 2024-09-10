Rails.application.routes.draw do
  devise_for :users
  root to: "restaurants#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :restaurants, only: %i[new create show]
  get "restaurant", to: "restaurants#roulette", as: :restaurants_roulette
end

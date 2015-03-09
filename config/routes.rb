Rails.application.routes.draw do
  devise_for :users

  resources :sports

  resources :users, only: :show
  
  root to: 'users#show'
end

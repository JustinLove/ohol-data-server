Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :lives, only: [:index]
  resources :servers, only: [:index]
  resources :family_trees, only: [:index]
end

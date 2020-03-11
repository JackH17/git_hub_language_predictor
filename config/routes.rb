Rails.application.routes.draw do
  root 'home#index'

  get 'new', to: "home#new"

  post 'search', to: "home#search"
  get 'show', to: "home#show"
  get 'search', to: "home#search"
end

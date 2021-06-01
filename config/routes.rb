Rails.application.routes.draw do
  resources :bills
  get 'calendar/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users

  root 'home#index'

  get 'calendar', to: 'calendar#index'
end

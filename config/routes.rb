Rails.application.routes.draw do
  resources :paydays
  resources :bills

  get 'calendar/index'

  devise_for :users

  root 'home#index'

  get 'calendar', to: 'calendar#index'

  post '/calendar_settings', to: 'calendar#settings'
end

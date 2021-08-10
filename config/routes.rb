Rails.application.routes.draw do
  get 'help', to: 'help#index'

  resources :paydays
  resources :bills

  get 'calendar/index'

  devise_for :users, controllers: { registrations: 'registrations' }

  root 'home#index'

  post '/calendar_settings', to: 'calendar#settings'
end

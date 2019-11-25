Rails.application.routes.draw do
  devise_for :users
  resources :timesheets
  resources :assignments
  resources :people
  resources :projects
  resources :clients
  
  get 'page/index'
  root to: 'page#index'
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

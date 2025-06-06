require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root to: 'dashboards#index'
  get '/dashboards/exploratory_data_analysis', to: 'dashboards#exploratory_data_analysis'
  get '/dashboards/company_data_visualization', to: 'dashboards#company_data_visualization'
  get '/dashboards/area_data_visualization', to: 'dashboards#area_data_visualization'
  get '/dashboards/user_data_visualization', to: 'dashboards#user_data_visualization'

  namespace :api do
    namespace :v1 do
      resources :users
      resources :departments
      resources :survey_responses
    end
  end
end

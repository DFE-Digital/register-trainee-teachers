require_relative "routes/sidekiq_routes"

Rails.application.routes.draw do
  extend SidekiqRoutes

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat

  get "/pages/:page", to: "pages#show"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/trainees/not-supported-route", to: "trainees/not_supported_routes#index"

  concern :confirmable do
    resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm"
  end

  resources :trainees, only: %i[index show new create update] do
    scope module: :trainees do
      resource :contact_details, concerns: :confirmable, only: %i[edit update], path: "/contact-details"
      resources :degrees
      resource :personal_details, concerns: :confirmable, only: %i[edit update], path: "/personal-details"
    end

    member do
      get "training-details", to: "trainees/training_details#edit"
      get "course-details", to: "trainees/course_details#edit"
    end
  end

  resources :trn_submissions, only: %i[create show]

  root to: "pages#show", defaults: { page: "start" }
end

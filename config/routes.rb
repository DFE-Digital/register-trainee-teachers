# frozen_string_literal: true

require_relative "routes/sidekiq_routes"

Rails.application.routes.draw do
  extend SidekiqRoutes

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/cookies", to: "pages#cookie_policy", as: :cookie_policy
  get "/privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "/data-requirements", to: "pages#data_requirements"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/trainees/not-supported-route", to: "trainees/not_supported_routes#index"

  get "/sign-in" => "sign_in#index"
  get "/sign-out" => "sign_out#index"

  get "/sign-in/user-not-found", to: "sign_in#new"

  if FeatureService.enabled?("use_dfe_sign_in")
    get "/auth/dfe/callback" => "sessions#callback"
    get "/auth/dfe/sign-out" => "sessions#signout"
  else
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#signout"
    post "/auth/developer/callback", to: "sessions#callback"
  end

  concern :confirmable do
    resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm"
  end

  scope module: :system_admin, path: "system-admin" do
    resources :providers, except: %i[edit update destroy] do
      resources :users, only: %i[new create]
    end
    resources :dttp_providers, only: %i[index show create]
  end

  resources :trainees, except: :edit do
    scope module: :trainees do
      resource :training_details, concerns: :confirmable, only: %i[edit update], path: "/training-details"
      resource :publish_course_details, only: %i[edit update], path: "/publish-course-details"
      resources :confirm_publish_course, only: %i[edit update], path: "confirm-publish-course"

      resource :course_details, concerns: :confirmable, only: %i[edit update], path: "/course-details"
      resource :contact_details, concerns: :confirmable, only: %i[edit update], path: "/contact-details"
      resource :trainee_id, concerns: :confirmable, only: %i[edit update], path: "/trainee-id"
      resource :start_date, concerns: :confirmable, only: %i[edit update], path: "/trainee-start-date"
      resource :training_route, only: %i[edit update], path: "/training-routes"

      get "/confirm-delete", to: "confirm_delete#show"

      namespace :degrees do
        get "/new/type", to: "type#new"
        post "/new/type", to: "type#create"
      end

      resources :degrees do
        collection do
          resource :confirm_details, as: :degrees_confirm, only: %i[show update], path: "/confirm"
        end
      end

      resource :personal_details, concerns: :confirmable, only: %i[show edit update], path: "/personal-details"

      namespace :diversity do
        get "/confirm", to: "confirm_details#show"
        post "/confirm", to: "confirm_details#update"
        put "/confirm", to: "confirm_details#update"
        resource :disclosure, only: %i[edit update], path: "/information-disclosed"
        resource :ethnic_group, only: %i[edit update], path: "/ethnic-group"
        resource :ethnic_background, only: %i[edit update], path: "/ethnic-background"
        resource :disability_disclosure, only: %i[edit update], path: "/disability-disclosure"
        resource :disability_detail, only: %i[edit update], path: "/disabilities"
      end

      resource :outcome_details, only: [], path: "outcome-details" do
        get "confirm"
        get "recommended"
        resource :outcome_date, only: %i[edit update], path: "/outcome-date"
      end

      resource :qts_recommendations, only: %i[create]

      resource :confirm_withdrawal, only: %i[show update], path: "/withdraw/confirm"
      resource :withdrawal, only: %i[show update], path: "/withdraw"

      resource :confirm_deferral, only: %i[show update], path: "/defer/confirm"
      resource :deferral, only: %i[show update], path: "/defer"

      resource :confirm_reinstatement, only: %i[show update], path: "/reinstate/confirm"
      resource :reinstatement, only: %i[show update], path: "/reinstate"

      resource :timeline, only: :show
    end

    member do
      get "course-details", to: "trainees/course_details#edit"
      get "publish-course-details", to: "trainees/publish_course_details#edit"
      get "check-details", to: "trainees/check_details#show"
      get "review-draft", to: "trainees/review_draft#show"
    end
  end

  resources :trn_submissions, only: %i[create show], param: :trainee_id

  root to: "pages#start"
end

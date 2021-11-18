# frozen_string_literal: true

Rails.application.routes.draw do
  extend SystemAdminRoutes
  extend ApiRoutes

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat

  get "/accessibility", to: "pages#accessibility", as: :accessibility
  get "/privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "/guidance", to: "pages#guidance"
  get "/check-data", to: "pages#check_data"

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/trainees/not-supported-route", to: "trainees/not_supported_routes#index"

  get "/sign-in" => "sign_in#index"
  get "/sign-out" => "sign_out#index"

  get "/sign-in/user-not-found", to: "sign_in#new"

  get "request-an-account", to: "request_an_account#index"

  if FeatureService.enabled?("use_dfe_sign_in")
    get "/auth/dfe/callback" => "sessions#callback"
    get "/auth/dfe/sign-out" => "sessions#signout"
  else
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#signout"
    post "/auth/developer/callback", to: "sessions#callback"
  end

  concern :confirmable do
    resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "/trainees/confirm_details"
  end

  resources :trainees, except: :edit do
    scope module: :trainees do
      resource :training_details, concerns: :confirmable, only: %i[edit update], path: "/training-details"
      resource :publish_course_details, only: %i[edit update], path: "/publish-course-details" do
        concerns :confirmable
      end

      resource :course_details, only: %i[edit update], path: "/course-details" do
        concerns :confirmable
        resource :itt_start_date, only: %i[edit update], path: "/start-date"
        resource :study_mode, only: %i[edit update], path: "/study-mode"
      end

      resource :confirm_deletes, only: :show, path: "/confirm-delete", as: :confirm_delete
      resource :check_details, only: :show, path: "/check-details"
      resource :review_drafts, only: :show, path: "/review-draft"
      resource :course_details, only: %i[edit update], path: "/course-details", path_names: { edit: "" }
      resource :publish_course_details, only: %i[edit update], path: "/publish-course-details", path_names: { edit: "" }

      resource :schools, concerns: :confirmable, only: %i[edit update], path: "/schools"
      resource :contact_details, concerns: :confirmable, only: %i[edit update], path: "/contact-details"
      resource :start_date, concerns: :confirmable, only: %i[edit update], path: "/trainee-start-date"
      resource :start_status, concerns: :confirmable, only: %i[edit update], path: "/trainee-start-status"
      resource :training_route, only: %i[edit update], path: "/training-routes"
      resource :course_education_phase, only: %i[edit update], path: "/course-education-phase"

      namespace :degrees do
        resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "confirm_details"
        get "/new/type", to: "type#new"
        post "/new/type", to: "type#create"
      end

      resources :degrees, only: %i[new edit create update destroy]

      namespace :funding do
        concerns :confirmable
        resource :training_initiative, only: %i[edit update], path: "/training-initiative"
        resource :bursary, only: %i[edit update], path: "/bursary"
      end

      resource :language_specialisms, only: %i[edit update], path: "/language-specialisms"

      resource :personal_details, concerns: :confirmable, only: %i[show edit update], path: "/personal-details"

      namespace :diversity do
        resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "confirm_details"
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

      resource :award_recommendations, only: %i[create]

      resource :confirm_withdrawal, only: %i[show update], path: "/withdraw/confirm"
      resource :withdrawal, only: %i[show update], path: "/withdraw"

      resource :confirm_deferral, only: %i[show update], path: "/defer/confirm"
      resource :deferral, only: %i[show update], path: "/defer"

      resource :confirm_reinstatement, only: %i[show update], path: "/reinstate/confirm"
      resource :reinstatement, only: %i[show update], path: "/reinstate"

      resources :lead_schools, only: %i[index], path: "/lead-schools"
      resource :lead_schools, only: %i[update edit], path: "/lead-schools"
      resources :employing_schools, only: %i[index], path: "/employing-schools"
      resource :employing_schools, only: %i[update edit], path: "/employing-schools"

      namespace :apply_applications, path: "/apply-application" do
        resource :trainee_data, only: %i[update edit], path: "/trainee-data"
        resource :course_details, only: %i[update edit], path: "/course-details"
        resource :confirm_courses, only: %i[show update], path: "/confirm-course"
      end

      resource :timeline, only: :show

      resource :subject_specialism, only: %i[edit update], path: "/subject-specialism/:position"
      resource :start_date_verification, only: %i[show create], path: "/start-date-verification"
      resource :forbidden_deletes, only: %i[show create], path: "/delete-forbidden"
      resource :forbidden_withdrawal, only: %i[show], path: "/withdrawal-forbidden"
    end
  end

  resources :trn_submissions, only: %i[create show], param: :trainee_id, path: "trainee-registrations"
  resource :cookie_preferences, only: %i[show update], path: "/cookies"

  resources :service_updates, only: %i[index], path: "service-updates"

  root to: "pages#start"
end

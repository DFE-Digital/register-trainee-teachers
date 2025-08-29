# frozen_string_literal: true

Rails.application.routes.draw do
  extend SystemAdminRoutes
  extend ApiRoutes
  extend AutocompleteRoutes

  mount Yabeda::Prometheus::Exporter => "/metrics"

  if Settings.dttp.portal_host.present?
    constraints(->(req) { req.host == Settings.dttp.portal_host }) do
      dttp_replaced_url = "#{Settings.base_url}/dttp-replaced"

      root to: redirect(dttp_replaced_url), as: :traineeteacherportal_root
      get "/*path", to: redirect(dttp_replaced_url), as: :traineeteacherportal
    end
  end

  get :ping, controller: :heartbeat
  get :healthcheck, controller: :heartbeat
  get :sha, controller: :heartbeat

  get "/accessibility", to: "pages#accessibility"
  get "/data-sharing-agreement", to: "pages#data_sharing_agreement"
  get "/dttp-replaced", to: "pages#dttp_replaced"
  get "/privacy-notice", to: "pages#privacy_notice"
  get "/privacy-policy", to: redirect("/privacy-notice")

  get "/404", to: "errors#not_found", via: :all, as: :not_found
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  get "/sign-in" => "sign_in#index"
  get "/sign-out" => "sign_out#index"

  get "/sign-in/user-not-found", to: "sign_in#new"

  get "request-an-account", to: "request_an_account#index"

  case Settings.features.sign_in_method
  when "dfe-sign-in"
    get("/auth/dfe/callback" => "sessions#callback")
    get("/auth/dfe/sign-out" => "sessions#signout")
  when "otp"
    resource(:otp, only: %i[show create], controller: :otp, path: "request-sign-in-code")
    resource(:otp_verifications, only: %i[show create], path: "sign-in-code")
  when "persona"
    get("/personas", to: "personas#index")
    get("/auth/developer/sign-out", to: "sessions#signout")
    post("/auth/developer/callback", to: "sessions#callback")
  end

  concern :confirmable do
    resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "/trainees/confirm_details"
  end

  resources :reference_data,
            only: [],
            param: :attribute,
            path: "reference-data/:reference_data_version",
            reference_data_version: /v[.0-9]+(-pre|-rc)?/,
            module: :reference_data do
    resource :download, only: :show
  end

  resources :drafts, only: :index

  resources :reports, only: :index do
    collection do
      get "itt-new-starter-data-sign-off", to: "reports#itt_new_starter_data_sign_off"
      get :bulk_recommend_export
      get :bulk_recommend_empty_export
      get :bulk_placement_export
      scope module: :reports, as: :reports do
        resources :performance_profiles, path: "performance-profiles", only: %i[index new create] do
          collection do
            get "confirmation", to: "performance_profiles#confirmation"
          end
        end

        resources :censuses, path: "censuses", only: %i[index new create] do
          collection do
            get "confirmation", to: "censuses#confirmation"
          end
        end

        resources :claims_degrees, path: "claims-degrees", only: %i[index]
      end
    end
  end

  namespace :bulk_update, path: "bulk-update" do
    get "/", to: "bulk_updates#index"

    resource :placements, only: %i[new create], path: "add-details" do
      resource :confirmation, only: %i[show]
    end

    resources :recommendations_uploads, only: %i[new create edit update], path: "recommend", path_names: { new: "choose-who-to-recommend", edit: "change-who-youll-recommend" } do
      get "confirmation"
      get "upload-summary", to: "recommendations_uploads#show", as: "summary"
      resource :recommendations, only: :create
      resource :recommendations_checks, only: :show, path: "check-who-youll-recommend"
      resource :recommendations_errors, only: %i[show create], path: "review-errors"
      member { get :cancel, path: "cancel" }
    end

    namespace :add_trainees, path: "add-trainees" do
      resources :uploads, only: %i[index show new create destroy] do
        member do
          resource :imports, only: :create
          resource :submission, only: %i[create]
        end
      end
      resource :empty_template, only: %i[show], path: "empty-template"
    end
  end

  resources :trainees, except: :edit do
    scope module: :trainees do
      namespace :lead_partners, path: "lead-partners" do
        resource :details, only: %i[edit update]
      end

      namespace :employing_schools, path: "employing-schools" do
        resource :details, only: %i[edit update]
      end

      resource :training_details, concerns: :confirmable, only: %i[edit update], path: "/training-details"
      resource :course_years, only: %i[edit update], path: "/course-years"
      resource :publish_course_details, only: %i[edit update], path: "/publish-course-details" do
        concerns :confirmable
      end

      resource :course_details, only: %i[edit update], path: "/course-details" do
        concerns :confirmable
        resource :itt_dates, only: %i[edit update], path: "/itt-dates"
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

      namespace :withdrawal do
        resource :start, only: :show
        resource :date, only: %i[edit update]
        resource :reason, only: %i[edit update]
        resource :trigger, only: %i[edit update]
        resource :future_interest, only: %i[edit update]
        resource :extra_information, only: %i[edit update], path: "extra-information"
        resource :confirm_detail, only: %i[edit update], path: "confirm"
      end

      resource :undo_withdrawal, only: %i[show edit update destroy], path: "undo-withdrawal" do
        scope module: :undo_withdrawals do
          resource :confirmation, only: %i[show update destroy]
        end
      end

      resource :confirm_deferral, only: %i[show update], path: "/defer/confirm"
      resource :deferral_reason, only: %i[show update], path: "/defer/reason"
      resource :deferral, only: %i[show update], path: "/defer"

      resource :confirm_reinstatement, only: %i[show update], path: "/reinstate/confirm"
      resource :reinstatement, only: %i[show update], path: "/reinstate" do
        scope module: :reinstatements do
          resource :update_end_date, only: %i[show update], path: "/update-end-date"
        end
      end

      resources :lead_partners, only: %i[index], path: "/lead-partners"
      resource :lead_partners, only: %i[edit update], path: "/lead-partners"
      resources :employing_schools, only: %i[index], path: "/employing-schools"
      resource :employing_schools, only: %i[update edit], path: "/employing-schools"

      resource :iqts_country, concerns: :confirmable, only: %i[edit update], path: "iqts-country"

      namespace :apply_applications, path: "/apply-application" do
        resource :trainee_data, only: %i[update edit], path: "/trainee-data"
        resource :course_details, only: %i[update edit], path: "/course-details"
        resource :confirm_courses, only: %i[show update], path: "/confirm-course"
      end

      resource :admin, only: :show

      resource :subject_specialism, only: %i[edit update], path: "/subject-specialism/:position"
      resource :start_date_verification, only: %i[show update], path: "/start-date-verification"
      resource :forbidden_deletes, only: %i[show create], path: "/delete-forbidden"
      resource :forbidden_withdrawal, only: %i[show], path: "/withdrawal-forbidden"

      namespace :hesa, path: nil do
        resource :enable_edits, only: %i[show update], path: "/editing-enabled"
      end

      namespace :interstitials, path: "/interstitial" do
        resource :hesa_deferrals, only: :show, path: "/defer"
        resource :hesa_reinstatements, only: :show, path: "/reinstate"
      end

      resources :placements, only: %i[new create edit update destroy] do
        get "delete", on: :member, to: "placements#delete", as: "delete"

        collection do
          scope module: :placements, as: :placements do
            resource :details, only: %i[edit update], path: "/details"

            resource :confirm_details, as: :confirm, only: %i[show update], path: "/confirm", controller: "confirm_details"
          end
        end
      end

      resources :placement_school_search, only: %i[new create edit update], controller: "placement_school_searches"
    end
  end

  resources :trn_submissions, only: %i[create show], param: :trainee_id, path: "trainee-registrations"
  resource :cookie_preferences, only: %i[show update], path: "/cookies"

  resources :service_updates, only: %i[index show], path: "service-updates"

  resources :organisations, only: %i[index show], path: "organisations"

  resource :organisation_settings, only: :show, path: "organisation-settings"

  resources :authentication_tokens, only: %i[index new create show], path: "token-manage" do
    resource :revoke, only: %i[show update], controller: "authentication_tokens/revokes"
  end

  resource :guidance, only: %i[show], controller: "guidance" do
    get "/about-register-trainee-teachers", to: "guidance#about_register_trainee_teachers"
    get "/dates-and-deadlines", to: "guidance#dates_and_deadlines"
    get "/manually-registering-trainees", to: "guidance#manually_registering_trainees"
    get "/registering-trainees-through-api-or-csv", to: "guidance#registering_trainees_through_api_or_csv"
    get "/check-data", to: "guidance#check_data"
    get "/census-sign-off", to: "guidance#census_sign_off"
    get "/performance-profiles", to: "guidance#performance_profiles"
    get "/bulk-recommend-trainees", to: "guidance#bulk_recommend_trainees"
    get "/withdraw-defer-reinstate-or-recommend-a-trainee", to: "guidance#withdraw_defer_reinstate_or_recommend_a_trainee"
    get "/manage-placements", to: "guidance#manage_placements"
    get "/bulk-upload-placement-data", to: "guidance#bulk_upload_placement_data"
    get "/how_to_extract_trns_from_the_register_service", to: "guidance#how_to_extract_trns_from_the_register_service"
  end

  if FeatureService.enabled?("funding")
    get "/funding", to: "funding#show", as: :funding

    namespace :funding do
      scope "(:academic_year)" do
        resource :payment_schedules, only: [:show], path: "payment-schedule", as: :payment_schedule
        resource :trainee_summaries, only: [:show], path: "trainee-summary", as: :trainee_summary
      end
    end
  end

  root to: "landing_page#start"
end

# frozen_string_literal: true

module SystemAdminRoutes
  def self.extended(router)
    router.instance_exec do
      scope module: :system_admin, path: "system-admin", constraints: RouteConstraints::SystemAdminConstraint.new do
        require "sidekiq/web"
        require "sidekiq/cron/web"

        mount Blazer::Engine, at: "/blazer", constraints: RouteConstraints::SystemAdminConstraint.new
        get "/blazer", to: redirect("/sign-in"), status: 302

        mount Sidekiq::Web, at: "/sidekiq", constraints: RouteConstraints::SystemAdminConstraint.new
        get "/sidekiq", to: redirect("/sign-in"), status: 302

        resources :pending_trns, only: %i[index show]
        resources :pending_awards, only: %i[index], path: "pending-status-change"
        resources :duplicate_apply_applications, only: %i[index show]

        get "funding-uploads", to: "funding_uploads#index", as: :funding_uploads

        resource :funding_uploads, only: %i[new create], path: "/funding-uploads" do
          scope module: :funding_uploads do
            resource :confirmation, only: %i[show], path: "/confirm-upload"
          end
        end

        # Funding management — "Add funding" wizard (write; gated by
        # funding_management_edit). Declared before the read-only scope so the
        # /add paths are not swallowed by the /:training_route catch-all.
        scope path: "funding-management/add", as: :funding_management_add do
          get   "/",              to: "add_funding#start",  as: :start
          get   "/check-answers", to: "add_funding#check",  as: :check
          post  "/",              to: "add_funding#create", as: :create
          get   "/:step",         to: "add_funding#show",   as: :step
          patch "/:step",         to: "add_funding#update"
        end

        # Funding management (read-only browse of funding reference data)
        scope path: "funding-management", as: :funding_management do
          get "/", to: "funding_management#index", as: :root
          get "/requirements", to: "funding_methods#index", as: :requirements
          get "/drafts", to: "funding_methods#drafts", as: :drafts
          get "/drafts/:academic_year/delete", to: "funding_methods#confirm_delete_draft", as: :delete_draft, constraints: { academic_year: /\d{4}/ }
          delete "/drafts/:academic_year", to: "funding_methods#destroy_draft", as: :destroy_draft, constraints: { academic_year: /\d{4}/ }
          # One-person sign off: review → approve (declaration) → confirmation; reopen until go-live.
          constraints(academic_year: /\d{4}/) do
            get "/drafts/:academic_year/sign-off", to: "draft_sign_offs#show", as: :draft_sign_off
            get "/drafts/:academic_year/sign-off/approve", to: "draft_sign_offs#approve", as: :approve_draft_sign_off
            post "/drafts/:academic_year/sign-off", to: "draft_sign_offs#create"
            get "/drafts/:academic_year/sign-off/confirmation", to: "draft_sign_offs#confirmation", as: :draft_sign_off_confirmation
            post "/drafts/:academic_year/reopen", to: "draft_sign_offs#reopen", as: :reopen_draft
          end
          get "/roll-over", to: "funding_methods#roll_over", as: :roll_over
          post "/roll-over", to: "funding_methods#create_roll_over", as: :create_roll_over
          # Delete draft funding (draft years only)
          delete "/delete-selected", to: "funding_methods#destroy_selected", as: :destroy_selected
          delete "/entries/:id", to: "funding_methods#destroy_entry", as: :destroy_entry, constraints: { id: /\d+/ }
          # Sign off is only through the Drafts sign-off journey (draft_sign_offs). These
          # steps finish a submission made under the old two-person flow, if one is still
          # awaiting approval; no new submissions can be made.
          get "/publish/review", to: "funding_methods#review_publication", as: :review_publication
          post "/publish/approve", to: "funding_methods#approve_publication", as: :approve_publication
          post "/publish/reject", to: "funding_methods#reject_publication", as: :reject_publication
          post "/publish/withdraw", to: "funding_methods#withdraw_publication", as: :withdraw_publication
          get "/reports", to: "funding_methods#reports", as: :reports
          get "/subject-records", to: "funding_methods#subject_records", as: :subject_records
          # Structured view was merged into Reports; keep old links working.
          get "/structured-view", to: redirect { |_params, request| "/system-admin/funding-management/reports#{"?#{request.query_string}" if request.query_string.present?}" }
          get "/schools", to: "funding_schools#index", as: :schools
          # Add a school: one question per page (academic year → designation →
          # school), then check the school's details and confirm.
          get "/schools/new", to: "funding_schools#start", as: :new_school
          get "/schools/add/check", to: "funding_schools#check", as: :school_check
          get "/schools/add/:step", to: "funding_schools#show", as: :school_step
          patch "/schools/add/:step", to: "funding_schools#update"
          post "/schools/confirm", to: "funding_schools#save", as: :save_school
          get "/schools/bulk-upload", to: "funding_schools#bulk_new", as: :bulk_new_schools
          post "/schools/bulk-upload", to: "funding_schools#bulk_create", as: :bulk_create_schools
          delete "/schools/:id", to: "funding_schools#destroy", as: :school, constraints: { id: /\d+/ }
          get "/relevant-degrees", to: "relevant_degrees#index", as: :relevant_degrees
          get "/relevant-degrees/add", to: "relevant_degrees#start", as: :new_relevant_degree
          get "/relevant-degrees/add/check-answers", to: "relevant_degrees#check", as: :relevant_degree_check
          post "/relevant-degrees", to: "relevant_degrees#create"
          get "/relevant-degrees/add/:step", to: "relevant_degrees#show", as: :relevant_degree_step
          patch "/relevant-degrees/add/:step", to: "relevant_degrees#update"
          delete "/relevant-degrees/:id", to: "relevant_degrees#destroy", as: :relevant_degree, constraints: { id: /\d+/ }
          get "/entries/:id", to: "funding_methods#entry", as: :entry, constraints: { id: /\d+/ }
          get "/subjects/:id", to: "funding_methods#subject", as: :subject, constraints: { id: /\d+/ }
          get "/:training_route", to: "funding_methods#show", as: :funding_method, constraints: { training_route: /[a-z_]+/ }
        end

        resources :providers, only: %i[index new create show edit update destroy] do
          resources :users, controller: "providers/users", only: %i[index edit update]

          get "/funding", to: "funding#show", as: :funding

          namespace :funding do
            scope "(:academic_year)" do
              resource :payment_schedules, only: %i[show], path: "/payment-schedule", as: :payment_schedule
              resource :trainee_summaries, only: %i[show], path: "/trainee-summary", as: :trainee_summary
            end
          end
          resource :confirm_deletes, only: :show, path: "/confirm-delete", as: :confirm_delete, module: :providers
        end

        resources :users do
          resources :providers, controller: "user_providers", only: %i[new create] do
            resource :accessions, controller: "providers/accessions", only: %i[edit destroy]
          end

          resources :training_partners, controller: "user_training_partners", only: %i[index new create], path: "training-partners" do
            resource :accessions, controller: "training_partners/accessions", only: %i[edit destroy]
          end

          member { get :delete }
        end

        resources :validation_errors, only: %i[index]
        resources :schools, only: %i[index show edit update] do
          scope module: :schools do
            resource :confirm_details, only: %i[show update], path: :confirm
          end
        end

        resources :training_partners, path: "training-partners", only: %i[index show] do
          resources :users, controller: "training_partners/users", only: %i[edit update]
        end

        resources :dttp_trainees, only: [:show], path: "dttp-trainees" do
          member do
            get :placement_assignments, path: "placement-assignments"
          end
        end

        resources :uploads, only: %i[index new create show destroy]

        namespace :trainee_deletions, path: "trainee-deletions" do
          resources :reasons, only: %i[edit update]
          resources :confirmations, only: %i[show update destroy]
        end

        namespace :pending_trns, path: "pending-trns" do
          resources :retrieve_trns, only: %i[update], path: "retrieve-trns"
          resources :request_trns, only: %i[update], path: "request-trns"
        end

        resources :trainees, only: [], path: "trainees" do
          namespace :accredited_providers, path: "accredited-providers" do
            resource :provider, only: %i[edit update]
            resource :reason, only: %i[edit update]
            resource :confirmations, only: %i[show update]
          end
        end
      end
    end
  end
end

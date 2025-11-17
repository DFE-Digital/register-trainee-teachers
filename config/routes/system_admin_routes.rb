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

        resources :dead_jobs, only: %i[index show update destroy]
        resources :pending_trns, only: %i[index show]
        resources :pending_awards, only: %i[index show]
        resources :duplicate_apply_applications, only: %i[index show]
        resources :duplicate_hesa_trainees, only: :index

        get "funding-uploads", to: "funding_uploads#index", as: :funding_uploads

        resource :funding_uploads, only: %i[new create], path: "/funding-uploads" do
          scope module: :funding_uploads do
            resource :confirmation, only: %i[show], path: "/confirm-upload"
          end
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

          resources :lead_partners, controller: "user_lead_partners", only: %i[index new create], path: "training-partners" do
            resource :accessions, controller: "lead_partners/accessions", only: %i[edit destroy]
          end

          member { get :delete }
        end

        resources :validation_errors, only: %i[index]
        resources :schools, only: %i[index show edit update] do
          scope module: :schools do
            resource :confirm_details, only: %i[show update], path: :confirm
          end
        end

        resources :lead_partners, path: "training-partners", only: %i[index show] do
          resources :users, controller: "lead_partners/users", only: %i[edit update]
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

# frozen_string_literal: true

module SystemAdminRoutes
  def self.extended(router)
    router.instance_exec do
      scope module: :system_admin, path: "system-admin" do
        require "sidekiq/web"
        require "sidekiq/cron/web"

        mount Blazer::Engine, at: "/blazer", constraints: SystemAdminConstraint.new
        get "/blazer", to: redirect("/sign-in"), status: 302

        mount Sidekiq::Web, at: "/sidekiq", constraints: SystemAdminConstraint.new
        get "/sidekiq", to: redirect("/sign-in"), status: 302

        resources :providers, only: %i[index new create show edit update] do
          resources :users, controller: "providers/users", only: %i[index edit update]

          namespace :funding do
            resource :payment_schedule, only: %i[show], path: "/payment-schedule"
            resource :trainee_summary, only: %i[show], path: "/trainee-summary"
          end
        end

        resources :users do
          resources :providers, controller: "user_providers", only: %i[new create] do
            resource :accessions, controller: "providers/accessions", only: %i[edit destroy]
          end

          resources :lead_schools, controller: "user_lead_schools", only: %i[index new create], path: "lead-schools" do
            resource :accessions, controller: "lead_schools/accessions", only: %i[edit destroy]
          end

          member { get :delete }
        end

        resources :validation_errors, only: %i[index]
        resources :schools, only: %i[index]

        resources :lead_schools, path: "lead-schools", only: %i[index show] do
          resources :users, controller: "lead_schools/users", only: %i[edit update]

          namespace :funding do
            resource :payment_schedule, only: %i[show], path: "/payment-schedule"
            resource :trainee_summary, only: %i[show], path: "/trainee-summary"
          end
        end

        resources :dttp_trainees, only: [:show], path: "dttp-trainees" do
          member do
            get :placement_assignments, path: "placement-assignments"
          end
        end
      end
    end
  end
end

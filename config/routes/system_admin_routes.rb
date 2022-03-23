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
          resources :dttp_users, only: %i[index], path: "/dttp-users"
          resources :users, controller: "providers/users", only: %i[index new create edit update destroy] do
            member do
              get "delete"
            end
          end

          scope module: :imports do
            post "/users/import", to: "users#create", as: :import_user
          end
        end

        resources :users do
          resources :providers, controller: "user_providers", only: %i[new create]
          resources :lead_schools, controller: "user_lead_schools", only: %i[index new create], path: "lead-schools"
        end
        resources :dttp_providers, only: %i[index show create]
        resources :validation_errors, only: %i[index]
        resources :schools, only: %i[index]
        resources :lead_schools, path: "lead-schools", only: %i[index show] do
          resources :users, controller: "lead_schools/users", only: %i[new create edit update]
        end
      end
    end
  end
end

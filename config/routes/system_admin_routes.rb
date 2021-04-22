# frozen_string_literal: true

module SystemAdminRoutes
  def self.extended(router)
    router.instance_exec do
      scope module: :system_admin, path: "system-admin" do
        resources :providers, except: %i[edit update destroy] do
          resources :users, only: %i[new create]

          scope module: :imports do
            post "/users/import", to: "users#create", as: :import_user
          end
        end

        resources :dttp_providers, only: %i[index show create]
        resources :validation_errors, only: %i[index]
      end
    end
  end
end

# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api do
        resources :schools, only: :index
        resources :providers, only: :index
        resources :users, only: :index
      end

      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+/ do
        resource :info, only: :show, controller: "info"
      end
    end
  end
end

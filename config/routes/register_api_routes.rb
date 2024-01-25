# frozen_string_literal: true

module RegisterApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :register_api, path: "register-api/:api_version", api_version: /v[.0-9]+/ do
        resource :info, only: :show, controller: "info"
      end
    end
  end
end

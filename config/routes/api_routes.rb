# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+/ do
        resources :trainees, only: %i[index show create], controller: "trainees", constraints: RouteConstraints::RegisterApiConstraint do
          scope module: :trainees do
            resource :withdraw, only: %i[create], path: "/withdraw"
          end
        end

        resource :info, only: :show, controller: "info", constraints: RouteConstraints::RegisterApiConstraint
        resource :guide, only: :show, controller: "guide", constraints: RouteConstraints::RegisterApiConstraint

        # NOTE: catch all route
        match "*url" => "base#render_not_found", via: :all
      end

      namespace :api_docs, path: "api-docs" do
        get "/" => "pages#show", as: :home
        get "/reference" => "reference#show", as: :reference
        get "/:api_version/reference" => "reference#show", constraints: { api_version: /v[.0-9]+/ }, as: :versioned_reference
        get "/:page" => "pages#show", as: :page
      end

      mount Yabeda::Prometheus::Exporter => "/metrics"
    end
  end
end

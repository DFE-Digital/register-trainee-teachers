# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+(-pre|-rc)?/, defaults: { format: :json } do
        resources :trainees, param: :slug, only: %i[index show update create], constraints: RouteConstraints::RegisterApiConstraint do
          scope module: :trainees do
            resource :withdraw, controller: :withdraw, only: :create
            resources :degrees, param: :degree_slug, only: %i[index show create update destroy]
            resources :placements, param: :placement_slug, only: %I[index show create update destroy]
            resources :award_recommendations, only: :create, path: "recommend-for-qts"
            resources :deferrals, only: :create, path: :defer
          end
        end

        resource :info, controller: :info, only: :show, constraints: RouteConstraints::RegisterApiConstraint

        # NOTE: catch all route
        match "*url" => "base#render_not_found", via: :all
      end

      namespace :api_docs, path: "api-docs" do
        get "/:api_version/openapi" => "openapi#show", constraints: { api_version: /v[.0-9]+(-pre|-rc)?/ }, as: :openapi
      end
    end
  end
end

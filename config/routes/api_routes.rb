# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+(-pre)?/, defaults: { format: :json } do
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
        get "/" => "pages#show", as: :home
        get "/reference" => "reference#show", as: :reference
        get "/hesa-reference" => "hesa_reference#index", as: :hesa_reference
        get "/:page" => "pages#show", as: :page

        constraints(api_version: /v[.0-9]+(-pre)?/) do
          get "/:api_version/openapi" => "openapi#show", as: :openapi
          get "/:api_version/reference" => "reference#show", as: :versioned_reference
          get "/:api_version/hesa-reference" => "hesa_reference#index", as: :versioned_hesa_reference
          get "/:api_version/hesa-reference/trainee/:attribute" => "hesa_references/trainees#show", as: :hesa_reference_trainee_attribute
          get "/:api_version/hesa-reference/degree/:attribute" => "hesa_references/degrees#show", as: :hesa_reference_degree_attribute
        end
      end

      namespace :csv_docs, path: "csv-docs" do
        get "/" => "pages#show", as: :home
      end
    end
  end
end

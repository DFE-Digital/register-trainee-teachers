# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+/ do
        resources :trainees, param: :slug, only: %i[index show update create], constraints: RouteConstraints::RegisterApiConstraint do
          scope module: :trainees do
            resource :withdraw, controller: :withdraw, only: :create
            resources :degrees, param: :slug, only: %i[index create update destroy]
            resources :placements, param: :slug, only: %I[index show create update destroy]
          end
        end

        resource :info, controller: :info, only: :show, constraints: RouteConstraints::RegisterApiConstraint
        resource :guide, controller: :guide, only: :show, constraints: RouteConstraints::RegisterApiConstraint

        # NOTE: catch all route
        match "*url" => "base#render_not_found", via: :all
      end

      namespace :api_docs, path: "api-docs" do
        get "/" => "pages#show", as: :home
        get "/reference" => "reference#show", as: :reference
        get "/:api_version/reference" => "reference#show", constraints: { api_version: /v[.0-9]+/ }, as: :versioned_reference
        get "/:page" => "pages#show", as: :page
      end
    end
  end
end

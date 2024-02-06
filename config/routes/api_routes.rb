# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api, path: "api/:api_version", api_version: /v[.0-9]+/ do
        resource :info, only: :show, controller: "info", constraints: RouteConstraints::RegisterApiConstraint
        resources :trainees, only: :show, controller: "trainees", constraints: RouteConstraints::RegisterApiConstraint
        resource :guide, only: :show, controller: "guide", constraints: RouteConstraints::RegisterApiConstraint
        match "*url" => "base#not_found", via: :all
      end

      namespace :api_docs, path: "api-docs" do
        get "/" => "pages#home", as: :home
        get "/release-notes" => "pages#release_notes", as: :release_notes
        get "/reference" => "reference#show", as: :reference
      end
    end
  end
end

# frozen_string_literal: true

module AutocompleteRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :autocomplete do
        resources :schools, only: :index
        resources :providers, only: :index
        resources :users, only: :index
      end
    end
  end
end

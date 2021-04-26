# frozen_string_literal: true

module ApiRoutes
  def self.extended(router)
    router.instance_exec do
      namespace :api do
        resources :schools, only: :index
      end
    end
  end
end

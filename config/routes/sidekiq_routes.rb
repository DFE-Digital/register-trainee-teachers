# frozen_string_literal: true

module SidekiqRoutes
  def self.extended(router)
    router.instance_exec do
      # Sidekiq Basic Auth implementation
      # https://github.com/mperham/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
      require "sidekiq/web"

      if Rails.env.production?
        Sidekiq::Web.use Rack::Auth::Basic do |username, password|
          sidekiq_username = Settings.sidekiq.username
          sidekiq_password = Settings.sidekiq.password
          utils = ActiveSupport::SecurityUtils

          utils.secure_compare(::Digest::SHA256.hexdigest(sidekiq_username), ::Digest::SHA256.hexdigest(username)) &
            utils.secure_compare(::Digest::SHA256.hexdigest(sidekiq_password), ::Digest::SHA256.hexdigest(password))
        end
      end

      mount Sidekiq::Web, at: "/sidekiq"
    end
  end
end

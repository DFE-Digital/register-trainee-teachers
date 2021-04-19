# frozen_string_literal: true

module SystemAdmin
  class UsersView
    attr_reader :provider, :users

    def initialize(provider)
      @provider = provider
      @users = provider.users.order(:last_name)
    end

    def registered
      users
    end

    def not_registered
      Dttp::User.not_registered_with_provider(
        provider.dttp_id,
        users.pluck(:dttp_id),
      )
    end
  end
end

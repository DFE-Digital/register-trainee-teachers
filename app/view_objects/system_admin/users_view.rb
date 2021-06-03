# frozen_string_literal: true

module SystemAdmin
  class UsersView
    def initialize(provider)
      @provider = provider
    end

    def registered
      @registered ||= provider.users.order(:last_name)
    end

    def not_registered
      @not_registered ||= ::Dttp::User.not_registered_with_provider(
        provider.dttp_id,
        registered.pluck(:dttp_id),
      ).where.not(email: nil)
    end

  private

    attr_reader :provider
  end
end

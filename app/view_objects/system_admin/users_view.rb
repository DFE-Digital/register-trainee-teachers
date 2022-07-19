# frozen_string_literal: true

module SystemAdmin
  class UsersView
    def initialize(provider)
      @provider = provider
    end

    def users
      @users ||= provider.users.kept.order(:last_name)
    end

  private

    attr_reader :provider
  end
end

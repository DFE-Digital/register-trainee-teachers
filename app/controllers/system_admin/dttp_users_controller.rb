# frozen_string_literal: true

module SystemAdmin
  class DttpUsersController < ApplicationController
    def index
      @users_view = UsersView.new(provider)
    end

  private

    def provider
      @provider ||= Provider.find(params[:provider_id])
    end
  end
end

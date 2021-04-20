# frozen_string_literal: true

module SystemAdmin
  module Imports
    class UsersController < ApplicationController
      def create
        authorize provider.users.create!(user_params)
        redirect_to provider_path(provider)
      end

    private

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end

      def dttp_user
        @dttp_user ||= ::Dttp::User.find(params[:dttp_user_id])
      end

      def user_params
        dttp_user.attributes.symbolize_keys.slice(:first_name, :last_name, :email, :dttp_id)
      end
    end
  end
end

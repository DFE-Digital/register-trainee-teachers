# frozen_string_literal: true

module SystemAdmin
  module Providers
    class AccessionsController < ApplicationController
      before_action :load_models

      def edit; end

      def destroy
        @provider.users.delete(@user)
        redirect_to(user_path(@user), flash: { success: "User access removed successfully" })
      end

    private

      def load_models
        @user = authorize(User.find(params[:user_id]))
        @provider = Provider.find(params[:provider_id])
      end
    end
  end
end

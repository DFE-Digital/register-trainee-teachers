# frozen_string_literal: true

module SystemAdmin
  class UserProvidersController < ApplicationController
    def new
      @user = User.find(params[:user_id])
      @providers = Provider.all
    end

    def create
      @user = User.find(params[:user_id])
      @provider = Provider.find_by(name: params.expect(provider: [:provider])[:provider])
      ProviderUser.find_or_create_by!(provider: @provider, user: @user)
      redirect_to(user_path(@user), flash: { success: "Provider added" })
    end
  end
end

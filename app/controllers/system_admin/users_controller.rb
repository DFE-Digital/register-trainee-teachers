# frozen_string_literal: true

module SystemAdmin
  class UsersController < ApplicationController
    def new
      @user = authorize provider.users.build
    end

    def create
      @user = authorize provider.users.build(user_params)
      if @user.save
        redirect_to provider_path(provider)
      else
        render :new
      end
    end

  private

    def provider
      @provider ||= Provider.find(params[:provider_id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :dttp_id)
    end
  end
end

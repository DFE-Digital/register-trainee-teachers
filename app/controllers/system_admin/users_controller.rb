# frozen_string_literal: true

module SystemAdmin
  class UsersController < ApplicationController
    def new
      @user = authorize(provider.users.build)
    end

    def create
      @user = authorize(provider.users.build(permitted_attributes(User)))
      if @user.save
        redirect_to(provider_path(provider), flash: { success: t(".success") })
      else
        render(:new)
      end
    end

    def edit
      user
      @provider = user.provider
    end

    def update
      user
      @provider = user.provider
      if user.update(permitted_attributes(@user))
        redirect_to(provider_path(provider), flash: { success: t(".success") })
      else
        render(:edit)
      end
    end

    def delete
      user
      @provider = user.provider
    end

    def destroy
      user.discard
      @provider = user.provider
      redirect_to(provider_path(@provider))
    end

  private

    def provider
      @provider ||= Provider.find(params[:provider_id])
    end

    def user
      @user ||= authorize(User.find(params[:id]))
    end
  end
end

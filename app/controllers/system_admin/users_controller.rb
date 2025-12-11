# frozen_string_literal: true

module SystemAdmin
  class UsersController < ApplicationController
    before_action :redirect, only: %i[delete destroy]
    before_action :user, only: %i[show delete destroy]

    def index
      @users = filtered_users(
        policy_scope(
          User.kept.includes(:providers, :training_partners),
          policy_scope_class: UserPolicy,
        ).order_by_last_name.page(params[:page] || 1).per(UserSearch::DEFAULT_LIMIT),
      )
    end

    def show; end

    def new
      @user = authorize(User.new)
    end

    def create
      @user = authorize(User.new(permitted_attributes(User)))
      if @user.save
        user = User.find_or_create_by!(email: @user.email)
        redirect_to(user_path(user), flash: { success: t(".success") })
      else
        render(:new)
      end
    end

    def delete; end

    def destroy
      @user.discard!
      redirect_to(users_path, flash: { success: "User deleted" })
    end

  private

    def redirect
      redirect_to(users_path, flash: { warning: "Admin users may not be deleted" }) if user.system_admin?
    end

    def user
      @user ||= authorize(User.kept.find(params[:id]))
    end

    def filtered_users(users)
      UserSearch.call(query: params[:search], scope: users).users
    end
  end
end

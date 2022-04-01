# frozen_string_literal: true

module SystemAdmin
  class UsersController < ApplicationController
    def index
      @users = filtered_users(policy_scope(User.kept, policy_scope_class: UserPolicy).order_by_last_name.page(params[:page] || 1))
    end

    def new
      @user = authorize(User.new)
    end

    def create
      @user = authorize(User.new(permitted_attributes(User)))
      if @user.save
        User.find_or_create_by!(email: @user.email)
        redirect_to(user_path(user), flash: { success: t(".success") })
      else
        render(:new)
      end
    end

    def show
      @user = user
    end

  private

    def user
      @user ||= authorize(User.find(params[:id]))
    end

    def filtered_users(users)
      if params[:search]
        users.where("last_name like ? or email like ?", "%#{params[:search]}%", "%#{params[:search]}%")
      else
        users
      end
    end
  end
end

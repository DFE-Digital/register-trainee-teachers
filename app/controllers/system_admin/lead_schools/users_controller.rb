# frozen_string_literal: true

module SystemAdmin
  module LeadSchools
    class UsersController < ApplicationController
      before_action :set_lead_school
      before_action :set_user, only: %i[edit update]

      def new
        @user = authorize(@lead_school.users.new)
      end

      def edit; end

      def update
        if @user.update(permitted_attributes(@user))
          redirect_to(lead_school_path(@lead_school), flash: { success: t(".success") })
        else
          render(:edit)
        end
      end

    private

      def set_lead_school
        @lead_school = policy_scope(School, policy_scope_class: LeadSchoolPolicy::Scope).find(params[:lead_school_id])
      end

      def set_user
        @user = authorize(User.find(params[:id]))
      end
    end
  end
end

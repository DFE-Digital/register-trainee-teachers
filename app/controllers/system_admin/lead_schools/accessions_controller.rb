# frozen_string_literal: true

module SystemAdmin
  module LeadSchools
    class AccessionsController < ApplicationController
      before_action :load_models

      def edit; end

      def destroy
        @lead_school.users.delete(@user)
        redirect_to(user_path(@user), flash: { success: "User access removed successfully" })
      end

    private

      def load_models
        @user = authorize(User.find(params[:user_id]))
        @lead_school = policy_scope(School, policy_scope_class: LeadSchoolPolicy::Scope).find(params[:lead_school_id])
      end
    end
  end
end

# frozen_string_literal: true

module SystemAdmin
  class UserLeadSchoolsController < ApplicationController
    before_action :set_user

    def new
      @lead_school_form = UserLeadSchoolsForm.new
    end

    def create
      @lead_school_form = UserLeadSchoolsForm.new(lead_school_params.merge(user: @user))

      if @lead_school_form.save!
        redirect_to(user_path(@user), flash: { success: "Lead school added" })
      else
        render(:new)
      end
    end

  private

    def lead_school_params
      params.require(:system_admin_user_lead_schools_form).permit(:lead_school_id)
    end

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end

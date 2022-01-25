# frozen_string_literal: true

module SystemAdmin
  class UserLeadSchoolsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
      @lead_schools = School.lead_only
    end

    def create
      @user = User.find(params[:user_id])
      @lead_school = School.find_by(name: params[:school][:lead_school])
      LeadSchoolUser.find_or_create_by!(lead_school: @lead_school, user: @user)
      redirect_to(user_path(@user), flash: { success: "Lead school added" })
    end
  end
end

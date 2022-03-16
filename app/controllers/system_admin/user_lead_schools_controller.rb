# frozen_string_literal: true

module SystemAdmin
  class UserLeadSchoolsController < ApplicationController
    before_action :set_user

    helper_method :query

    def index
      @lead_school_form = UserLeadSchoolsForm.new
      @school_search = SchoolSearch.call(query: query, lead_schools_only: true)
    end

    def new
      @lead_school_form = UserLeadSchoolsForm.new
    end

    def create
      @lead_school_form = UserLeadSchoolsForm.new(lead_school_params.merge(user: @user))

      if @lead_school_form.school_not_selected? && @lead_school_form.valid?
        return redirect_to(user_lead_schools_path(query: query))
      end

      if @lead_school_form.save!
        redirect_to(user_path(@user), flash: { success: "Lead school added" })
      else
        @school_search = SchoolSearch.call(query: params[:query], lead_schools_only: true)
        render(index_or_new_page)
      end
    end

  private

    def lead_school_params
      params.fetch(:system_admin_user_lead_schools_form, {})
            .permit(UserLeadSchoolsForm::FIELDS)
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def query
      lead_school_params[:results_search_again_query].presence || lead_school_params[:no_results_search_again_query] || lead_school_params[:query] || params[:query]
    end

    def index_or_new_page
      @lead_school_form.search_results_found? || @lead_school_form.no_results_searching_again? ? :index : :new
    end
  end
end

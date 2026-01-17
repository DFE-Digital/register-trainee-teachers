# frozen_string_literal: true

module SystemAdmin
  class SchoolsController < ApplicationController
    def index
      @schools = policy_scope(School).order_by_name.page(params[:page] || 1)
    end

    def show
      @school_form = SchoolForm.new(school)
      @school_form.clear_stash
    end

    def edit
      @school_form = SchoolForm.new(school)
    end

    def update
      @school_form = SchoolForm.new(school, params: school_params)

      if @school_form.stash
        redirect_to(school_confirm_details_path(school))
      else
        render(:edit)
      end
    end

  private

    def school
      policy_scope(School).find(params[:id])
    end

    def school_params
      params.expect(school: [:training_partner])
    end
  end
end

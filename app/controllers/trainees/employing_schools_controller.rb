# frozen_string_literal: true

module Trainees
  class EmployingSchoolsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_schools

    def index
      @employing_school_form = EmployingSchoolForm.new(trainee)
    end

    def update
      @employing_school_form = EmployingSchoolForm.new(trainee, params: trainee_params, user: current_user)
      save_strategy = trainee.draft? ? :save! : :stash

      if @employing_school_form.public_send(save_strategy)
        redirect_to trainee_training_details_confirm_path(trainee)
      else
        render :index
      end
    end

  private

    def load_schools
      @schools = SchoolSearch.call(query: params[:query])
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.fetch(:employing_school_form, {}).permit(:employing_school_id)
    end

    def authorize_trainee
      authorize(trainee, :requires_employing_school?)
    end
  end
end

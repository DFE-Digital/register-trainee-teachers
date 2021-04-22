# frozen_string_literal: true

module Trainees
  class LeadSchoolsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_schools

    def index
      @trainee_lead_school_form = TraineeLeadSchoolForm.new(trainee)
    end

    def update
      @trainee_lead_school_form = TraineeLeadSchoolForm.new(trainee, params: trainee_params, user: current_user)
      save_strategy = trainee.draft? ? :save! : :stash

      if @trainee_lead_school_form.public_send(save_strategy)
        redirect_to trainee_training_details_confirm_path(@trainee_lead_school_form.trainee)
      else
        render :index
      end
    end

  private

    def load_schools
      @schools = SchoolSearch.call(query: params[:query], lead_schools_only: true)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.fetch(:trainee_lead_school_form, {}).permit(:lead_school_id)
    end

    def authorize_trainee
      authorize(trainee, :requires_schools?)
    end
  end
end

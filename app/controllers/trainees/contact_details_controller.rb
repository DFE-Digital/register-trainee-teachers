# frozen_string_literal: true

module Trainees
  class ContactDetailsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @contact_details = ContactDetailsForm.new(trainee)
    end

    def update
      @contact_details = ContactDetailsForm.new(trainee, contact_details_params)
      save_strategy = trainee.draft? ? :save! : :stash

      if @contact_details.public_send(save_strategy)
        redirect_to trainee_contact_details_confirm_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def contact_details_params
      params.require(:contact_details_form).permit(*ContactDetailsForm::FIELDS)
    end

    def section_completed?
      ProgressService.call(
        validator: ContactDetailsForm.new(trainee),
        progress_value: trainee.progress.contact_details,
      ).completed?
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end

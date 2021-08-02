# frozen_string_literal: true

module Trainees
  class ContactDetailsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @contact_details_form = ContactDetailsForm.new(trainee)
    end

    def update
      @contact_details_form = ContactDetailsForm.new(trainee, params: contact_details_params, user: current_user)

      save_strategy = trainee.draft? ? :save! : :stash

      if @contact_details_form.public_send(save_strategy)
        redirect_to relevant_redirect_path
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

    def authorize_trainee
      authorize(trainee)
    end

    def relevant_redirect_path
      trainee.apply_application? ? page_tracker.last_origin_page_path : trainee_contact_details_confirm_path(trainee)
    end
  end
end

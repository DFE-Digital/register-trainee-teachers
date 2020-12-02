# frozen_string_literal: true

module Trainees
  class ContactDetailsController < ApplicationController
    def edit
      authorize trainee
      @contact_details = ContactDetail.new(trainee)
    end

    def update
      authorize trainee
      trainee.assign_contact_details(contact_details_params)

      contact_detail = ContactDetail.new(trainee)

      if contact_detail.save
        redirect_to_confirm
      else
        @contact_details = contact_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def contact_details_params
      params.require(:contact_detail).permit(
        *ContactDetail::FIELDS,
      )
    end

    def redirect_to_confirm
      redirect_to trainee_contact_details_confirm_path(trainee)
    end

    def section_completed?
      ProgressService.call(
        validator: ContactDetail.new(trainee),
        progress_value: trainee.progress.contact_details,
      ).completed?
    end
  end
end

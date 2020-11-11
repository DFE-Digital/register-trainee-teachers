module Trainees
  class ContactDetailsController < ApplicationController
    def edit
      @contact_details = ContactDetail.new(trainee: trainee)
    end

    def update
      updater = ContactDetails::Update.call(trainee: trainee, attributes: contact_details_params)

      if updater.successful?
        redirect_to trainee_contact_details_confirm_path(trainee)
      else
        @contact_details = updater.contact_details
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
  end
end

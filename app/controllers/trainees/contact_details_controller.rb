module Trainees
  class ContactDetailsController < ApplicationController
    def edit
      trainee
    end

    def update
      if ContactDetails::Update.call(trainee: trainee, attributes: contact_details_params)
        redirect_to trainee_contact_details_confirm_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def contact_details_params
      params.require(:trainee).permit(
        :locale_code,
        :international_address,
        :address_line_one,
        :address_line_two,
        :town_city,
        :postcode,
        :phone_number,
        :email,
      )
    end
  end
end

module Trainees
  class ContactDetailsController < ApplicationController
    def edit
      trainee
    end

    def update
      ContactDetails::Update.call(trainee: trainee, attributes: contact_details_params)
      redirect_to trainee_path(trainee)
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

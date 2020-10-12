module Trainees
  class PersonalDetailsController < ApplicationController
    def edit
      trainee
      nationalities
      @personal_detail = PersonalDetail.new(trainee: trainee)
    end

    def update
      nationalities
      updater = PersonalDetails::Update.call(trainee: trainee, attributes: personal_details_params)

      if updater.successful?
        redirect_to trainee_personal_details_confirm_path(updater.personal_detail.trainee)
      else
        @personal_detail = updater.personal_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def nationalities
      @nationalities ||= Nationality.where(name: %w[british irish other])
    end

    def personal_details_params
      params.require(:personal_detail).permit(
        *PersonalDetail::FIELDS,
        nationality_ids: [],
      )
    end
  end
end

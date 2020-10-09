module Trainees
  class PersonalDetailsController < ApplicationController
    def edit
      nationalities
      @personal_details_form = PersonalDetailsForm.new(trainee: trainee)
    end

    def update
      nationalities
      @personal_details_form = PersonalDetailsForm.new(trainee: trainee, params: personal_details_params)

      if @personal_details_form.submit
        redirect_to trainee_path(@personal_details_form.trainee)
      else
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
      params.require(:personal_details_form).permit(
        :first_names,
        :middle_names,
        :last_name,
        :date_of_birth,
        :gender,
        nationality_ids: [],
      )
    end
  end
end

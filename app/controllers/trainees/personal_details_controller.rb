module Trainees
  class PersonalDetailsController < ApplicationController
    before_action :redirect_to_confirm, if: :section_completed?

    def edit
      trainee
      nationalities
      @personal_detail = PersonalDetail.new(trainee)
    end

    def update
      nationalities
      trainee.assign_attributes(personal_details_params)
      personal_detail = PersonalDetail.new(trainee)

      if personal_detail.valid?
        redirect_to trainee_personal_details_confirm_path(personal_detail.trainee)
      else
        @personal_detail = personal_detail
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

    def redirect_to_confirm
      redirect_to(trainee_personal_details_confirm_path(trainee))
    end

    def section_completed?
      ProgressService.call(
        validator: PersonalDetail.new(trainee),
        progress_value: trainee.progress.personal_details,
      ) == Progress::STATUSES[:completed]
    end
  end
end

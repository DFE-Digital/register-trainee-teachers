module Trainees
  class ProgrammeDetailsController < ApplicationController
    def edit
      trainee
      @programme_detail = ProgrammeDetail.new(trainee: trainee)
    end

    def update
      updater = ProgrammeDetails::Update.call(trainee: trainee,
                                              attributes: programme_details_params)
      if updater.successful?
        redirect_to trainee_path(trainee)
      else
        @programme_detail = updater.programme_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def programme_details_params
      params.require(:programme_detail).permit(
        :subject,
        :age_range,
        :programme_start_date,
      )
    end
  end
end

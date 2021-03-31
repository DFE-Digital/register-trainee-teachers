# frozen_string_literal: true

module Trainees
  class CourseDetailsController < ApplicationController
    before_action :authorize_trainee

    COURSE_DATE_CONVERSION = {
      "course_start_date(3i)" => "start_day",
      "course_start_date(2i)" => "start_month",
      "course_start_date(1i)" => "start_year",
      "course_end_date(3i)" => "end_day",
      "course_end_date(2i)" => "end_month",
      "course_end_date(1i)" => "end_year",
    }.freeze

    def edit
      @course_details_form = CourseDetailsForm.new(trainee)
    end

    def update
      @course_details_form = CourseDetailsForm.new(trainee, course_details_params.merge(course_date_params))
      save_strategy = trainee.draft? ? :save! : :stash
      if @course_details_form.public_send(save_strategy)
        redirect_to trainee_course_details_confirm_path(trainee)
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def course_details_params
      params.require(:course_details_form).permit(*CourseDetailsForm::FIELDS)
    end

    def course_date_params
      params.require(:course_details_form).except(
        *CourseDetailsForm::FIELDS,
      ).permit(*COURSE_DATE_CONVERSION.keys)
      .transform_keys { |key| COURSE_DATE_CONVERSION[key] }
    end

    def redirect_to_confirm
      redirect_to(trainee_course_details_confirm_path(trainee))
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end

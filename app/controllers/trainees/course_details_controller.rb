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

    COURSE_DETAILS_PARAMS_KEYS = %i[subject, subject_raw
                                    main_age_range
                                    additional_age_range,
                                    additional_age_range_raw].freeze

    def edit
      @course_detail = CourseDetailForm.new(trainee)
    end

    def update
      updater = CourseDetails::Update.call(trainee: trainee, attributes: course_details_params)

      if updater.successful?
        redirect_to trainee_course_details_confirm_path(trainee)
      else
        @course_detail = updater.course_detail
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def course_details_params
      params.require(:course_detail_form).permit(
        *COURSE_DETAILS_PARAMS_KEYS,
      ).except(*COURSE_DATE_CONVERSION.keys)
      .merge(course_date_params)
    end

    def course_date_params
      params.require(:course_detail_form).except(
        *COURSE_DETAILS_PARAMS_KEYS,
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

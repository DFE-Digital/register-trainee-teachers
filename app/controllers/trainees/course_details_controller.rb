# frozen_string_literal: true

module Trainees
  class CourseDetailsController < ApplicationController
    before_action :authorize_trainee

    DATE_CONVERSION = {
      "_start_date(3i)" => "start_day",
      "_start_date(2i)" => "start_month",
      "_start_date(1i)" => "start_year",
      "_end_date(3i)" => "end_day",
      "_end_date(2i)" => "end_month",
      "_end_date(1i)" => "end_year",
    }.freeze

    def edit
      @course_details_form = CourseDetailsForm.new(trainee)
    end

    def update
      @course_details_form = CourseDetailsForm.new(
        trainee,
        user: current_user,
        params: course_details_params.merge(course_date_params),
      )

      save_strategy = trainee.draft? ? :save! : :stash

      if @course_details_form.public_send(save_strategy)
        redirect_to relevant_redirect_path
      else
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def date_conversion
      @date_conversion ||= DATE_CONVERSION.transform_keys do |key|
        "#{trainee.itt_route? ? 'itt' : 'course'}#{key}"
      end
    end

    def course_details_params
      params.require(:course_details_form).permit(*CourseDetailsForm::FIELDS)
    end

    def course_date_params
      params.require(:course_details_form).except(
        *CourseDetailsForm::FIELDS,
      ).permit(*date_conversion.keys)
      .transform_keys { |key| date_conversion[key] }
    end

    def redirect_to_confirm
      redirect_to(trainee_course_details_confirm_path(trainee))
    end

    def authorize_trainee
      authorize(trainee)
    end

    def relevant_redirect_path
      apply_application_and_not_reviewing_course? ? page_tracker.last_origin_page_path : trainee_course_details_confirm_path(trainee)
    end

    def apply_application_and_not_reviewing_course?
      # If there is an application and they are confirming their course for the first time
      # the page_tracker.last_origin_page_path will be the review draft page so we don't want to redirect
      # there in this instance, they need to go to the course details confirm page
      trainee.apply_application? && trainee.draft? && !page_tracker.last_origin_page_path.include?("/review-draft")
    end
  end
end

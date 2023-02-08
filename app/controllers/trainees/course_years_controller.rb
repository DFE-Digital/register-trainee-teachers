# frozen_string_literal: true

module Trainees
  class CourseYearsController < BaseController
    def edit
      @course_years_form = CourseYearsForm.new(trainee:)
    end

    def update
      @course_years_form = CourseYearsForm.new(trainee: trainee, params: course_years_params)
      if @course_years_form.valid?
        Trainees::Update.call(trainee: trainee, params: { course_uuid: nil })
        redirect_to(edit_trainee_publish_course_details_path(trainee, year: @course_years_form.course_year))
      else
        render(:edit)
      end
    end

  private

    def course_years_params
      params.fetch(:course_years_form, {}).permit(:course_year)
    end
  end
end

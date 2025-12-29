# frozen_string_literal: true

module Trainees
  class TrainingRoutesController < BaseController
    helper_method :training_route

    def edit
      @training_routes_form = TrainingRoutesForm.new(trainee, params: params.slice(:context).permit!)
    end

    def update
      @training_routes_form = TrainingRoutesForm.new(trainee, params: trainee_params, user: current_user)

      if @training_routes_form.stash_or_save!
        redirect_to(relevant_redirect_path)
      else
        render(:edit)
      end
    end

  private

    def relevant_redirect_path
      if @training_routes_form.course_change?
        if trainee.available_courses(training_route).present?
          edit_trainee_publish_course_details_path(trainee)
        elsif EARLY_YEARS_TRAINING_ROUTES.include?(training_route)
          edit_trainee_course_details_path(trainee)
        else
          edit_trainee_course_education_phase_path(trainee)
        end
      elsif page_tracker.last_origin_page_path.present?
        page_tracker.last_origin_page_path
      else
        trainee_path(trainee)
      end
    end

    def trainee_params
      params.expect(training_routes_form: %i[training_route context])
    end
  end
end

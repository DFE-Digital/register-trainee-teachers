# frozen_string_literal: true

module Trainees
  module EmployingSchools
    class DetailsController < BaseController
      def edit
        @employing_school_form = Schools::EmployingSchoolForm.new(trainee)
      end

      def update
        @employing_school_form = Schools::EmployingSchoolForm.new(trainee, params: trainee_params, user: current_user)

        if @employing_school_form.stash_or_save!
          redirect_to(edit_trainee_employing_schools_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        params.fetch(:schools_employing_school_form, {})
          .permit(*Schools::EmployingSchoolForm::FIELDS,
                  *Schools::EmployingSchoolForm::NON_TRAINEE_FIELDS)
      end
    end
  end
end

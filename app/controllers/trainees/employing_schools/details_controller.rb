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
          if @employing_school_form.school_applicable?
            redirect_to(edit_trainee_employing_schools_path(trainee))
          else
            redirect_to(trainee_schools_confirm_path(trainee))
          end
        else
          render(:edit)
        end
      end

    private

      def trainee_params
        params
          .expect(schools_employing_school_form: [:employing_school_not_applicable])
      end
    end
  end
end

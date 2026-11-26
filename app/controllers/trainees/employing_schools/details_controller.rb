# frozen_string_literal: true

module Trainees
  module EmployingSchools
    class DetailsController < BaseController
      before_action :employing_setting_route

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

      # The early years teacher degree apprenticeship asks whether the apprentice
      # employing setting has a URN instead.
      def employing_setting_route
        redirect_to(edit_trainee_employing_settings_urn_path(trainee)) if trainee.requires_employing_setting?
      end

      def trainee_params
        params
          .expect(schools_employing_school_form: [:employing_school_not_applicable])
      end
    end
  end
end

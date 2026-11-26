# frozen_string_literal: true

module Trainees
  module EmployingSettings
    # Early years teacher degree apprenticeship: the apprentice employing setting's
    # name and address, filled in from the search or typed in.
    class DetailsController < BaseController
      before_action :employing_setting_route

      def edit
        @employing_setting_form = Schools::EmployingSettingForm.new(trainee)

        if (school = School.find_by(id: params[:school_id]))
          @employing_setting_form.fill_in_from(school) unless same_setting?(school)
        elsif params[:setting].to_s == "typed"
          @employing_setting_form.type_in
        elsif @employing_setting_form.from_search? && @employing_setting_form.employing_school_name.blank?
          # Chosen from the search before the setting's details were asked for.
          @employing_setting_form.fill_in_from(@employing_setting_form.school)
        end
      end

      def update
        @employing_setting_form = Schools::EmployingSettingForm.new(trainee, params: trainee_params, user: current_user)

        if @employing_setting_form.stash_or_save!
          redirect_to(trainee_schools_confirm_path(trainee))
        else
          render(:edit)
        end
      end

    private

      # The setting already saved, so the provider's address isn't replaced.
      def same_setting?(school)
        @employing_setting_form.employing_school_id.to_s == school.id.to_s && @employing_setting_form.employing_school_name.present?
      end

      def trainee_params
        params.expect(schools_employing_setting_form: Schools::EmployingSettingForm::EDITABLE_FIELDS)
      end

      def employing_setting_route
        redirect_to(trainee_path(trainee)) unless trainee.requires_employing_setting?
      end
    end
  end
end

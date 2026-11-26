# frozen_string_literal: true

module Trainees
  module EmployingSettings
    # Early years teacher degree apprenticeship: "Does the apprentice employing
    # setting have a URN?" Yes searches for it; no types it in.
    class UrnsController < BaseController
      before_action :employing_setting_route

      def edit
        @urn_form = Schools::EmployingSettingUrnForm.for(trainee)
      end

      def update
        @urn_form = Schools::EmployingSettingUrnForm.new(trainee: trainee, has_urn: params.dig(:schools_employing_setting_urn_form, :has_urn))
        return render(:edit) unless @urn_form.valid?

        if @urn_form.urn?
          redirect_to(edit_trainee_employing_schools_path(trainee))
        else
          redirect_to(edit_trainee_employing_settings_details_path(trainee, setting: :typed))
        end
      end

    private

      def employing_setting_route
        redirect_to(trainee_path(trainee)) unless trainee.requires_employing_setting?
      end
    end
  end
end

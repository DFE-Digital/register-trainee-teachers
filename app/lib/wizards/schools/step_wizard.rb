# frozen_string_literal: true

module Wizards
  module Schools
    class StepWizard
      include Rails.application.routes.url_helpers

      def initialize(trainee:, page_tracker: nil)
        @trainee = trainee
        @page_tracker = page_tracker
      end

      def next_step
        origin_page_or_next_step
      end

      def start_point
        return unless any_form_incomplete?
        return edit_trainee_lead_schools_path(trainee) unless lead_school_selected?

        edit_trainee_employing_schools_path(trainee)
      end

    private

      attr_reader :trainee, :page_tracker

      def any_form_incomplete?
        ProgressService.call(
          validator: ::Schools::FormValidator.new(trainee, non_search_validation: true),
          progress_value: trainee.progress.schools,
        ).in_progress_invalid?
      end

      def redirect_url
        trainee.requires_employing_school? ? edit_trainee_employing_schools_path(trainee) : trainee_schools_confirm_path(trainee)
      end

      def origin_page_or_next_step
        return trainee_schools_confirm_path(trainee) if user_come_from_confirm_or_trainee_page?

        redirect_url
      end

      def user_come_from_confirm_or_trainee_page?
        page_tracker.last_origin_page_path&.include?("schools/confirm") || page_tracker.last_origin_page_path == "/trainees/#{trainee.slug}"
      end

      def lead_school_selected?
        ::Schools::LeadSchoolForm.new(trainee, params: { non_search_validation: true }).valid?
      end

      def employing_school_selected?
        ::Schools::EmployingSchoolForm.new(trainee, params: { non_search_validation: true }).valid?
      end
    end
  end
end

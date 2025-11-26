# frozen_string_literal: true

module Wizards
  class SchoolsStepWizard
    include Rails.application.routes.url_helpers

    def initialize(trainee:, page_tracker: nil)
      @trainee = trainee
      @page_tracker = page_tracker
    end

    def next_step
      origin_page_or_next_step
    end

    def start_point
      return unless forms_to_complete?
      return edit_trainee_training_partners_path(trainee) unless lead_partner_selected?

      edit_trainee_employing_schools_path(trainee)
    end

  private

    attr_reader :trainee, :page_tracker

    def forms_to_complete?
      progress_service.not_started? || progress_service.in_progress_invalid?
    end

    def redirect_url
      trainee.requires_employing_school? ? edit_trainee_employing_schools_details_path(trainee) : trainee_schools_confirm_path(trainee)
    end

    def origin_page_or_next_step
      return trainee_schools_confirm_path(trainee) if user_came_from_confirm_or_trainee_page?

      redirect_url
    end

    def user_came_from_confirm_or_trainee_page?
      page_tracker.last_origin_page_path&.include?("schools/confirm") || page_tracker.last_origin_page_path == "/trainees/#{trainee.slug}"
    end

    def lead_partner_selected?
      ::Partners::TrainingPartnerForm.new(trainee, params: { non_search_validation: true }).valid?
    end

    def progress_service
      @progress_service ||= ProgressService.call(
        validator: ::Schools::FormValidator.new(trainee, non_search_validation: true),
        progress_value: trainee.progress.schools,
      )
    end
  end
end

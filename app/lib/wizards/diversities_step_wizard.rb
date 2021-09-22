# frozen_string_literal: true

module Wizards
  class DiversitiesStepWizard
    include Rails.application.routes.url_helpers

    def initialize(trainee:, page_tracker: nil)
      @trainee = trainee
      @page_tracker = page_tracker
    end

    def next_step
      if disclosure_form.diversity_disclosed?
        edit_trainee_diversity_ethnic_group_path(trainee)
      else
        trainee_diversity_confirm_path(trainee)
      end
    end

    def start_point
      return unless any_form_incomplete?
      return edit_trainee_diversity_disclosure_path(trainee) unless ::Diversities::DisclosureForm.new(trainee).valid?
      return edit_trainee_diversity_ethnic_group_path(trainee) unless ::Diversities::EthnicGroupForm.new(trainee).valid?
      return edit_trainee_diversity_ethnic_background_path(trainee) unless ::Diversities::EthnicBackgroundForm.new(trainee).valid?
      return edit_trainee_diversity_disability_disclosure_path(trainee) unless ::Diversities::DisabilityDisclosureForm.new(trainee).valid?

      edit_trainee_diversity_disability_detail_path(trainee)
    end

  private

    attr_reader :trainee, :page_tracker

    def any_form_incomplete?
      ProgressService.call(
        validator: ::Diversities::FormValidator.new(trainee),
        progress_value: trainee.progress.diversity,
      ).in_progress_invalid?
    end

    def disclosure_form
      @disclosure_form ||= ::Diversities::DisclosureForm.new(trainee)
    end
  end
end

# frozen_string_literal: true

module Trainees
  class CreateFromApplyJob < ApplicationJob
    queue_as :apply

    def perform
      return unless FeatureService.enabled?("import_applications_from_apply") && !Rails.env.sandbox?

      ApplyApplication.joins(:provider).where(
        providers: { apply_sync_enabled: true },
        recruitment_cycle_year: Settings.apply_applications.create.recruitment_cycle_year,
      ).importable.find_each do |application|
        CreateFromApplicationJob.perform_later(application)
      end
    end
  end
end

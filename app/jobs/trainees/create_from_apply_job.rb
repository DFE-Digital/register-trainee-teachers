# frozen_string_literal: true

module Trainees
  class CreateFromApplyJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_applications_from_apply")

      ApplyApplication.joins(:provider).where(
        providers: { apply_sync_enabled: true },
        recruitment_cycle_year: Settings.apply_applications.create.recruitment_cycle_year,
      ).importable.each do |application|
        CreateFromApply.call(application: application)
      rescue Trainees::CreateFromApply::MissingCourseError => e
        Sentry.capture_exception(e)
      end
    end
  end
end

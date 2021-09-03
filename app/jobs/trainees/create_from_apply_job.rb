# frozen_string_literal: true

module Trainees
  class CreateFromApplyJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_applications_from_apply")

      ApplyApplication.joins(:provider).importable.each do |application|
        CreateFromApply.call(application: application)
      end
    end
  end
end

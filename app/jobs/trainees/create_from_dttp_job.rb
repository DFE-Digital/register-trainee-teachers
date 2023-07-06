# frozen_string_literal: true

module Trainees
  class CreateFromDttpJob < ApplicationJob
    queue_as :default

    USERNAME = "DTTP"

    def perform(dttp_trainee)
      return unless FeatureService.enabled?("import_trainees_from_dttp")

      Audited.audit_model.as_user(USERNAME) do
        CreateFromDttp.call(dttp_trainee:)
      end
    end
  end
end

# frozen_string_literal: true

module Trs
  class UpdateTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :trs

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)
      return unless trainee_updatable?(trainee)

      UpdatePersonalData.call(trainee:)
    end

  private

    def trainee_updatable?(trainee)
      current_trainee = trainee.reload

      current_trainee.trn.present? &&
        ::CodeSets::Trs.valid_for_update?(current_trainee.state)
    end
  end
end

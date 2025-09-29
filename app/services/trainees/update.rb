# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern
    include HandlesIntegrationConflicts

    def initialize(trainee:, params: {}, update_trs: true)
      @trainee = trainee
      @params = params
      @update_trs = update_trs
      @dqt_enabled = FeatureService.enabled?(:integrate_with_dqt)
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      # Pass update_trs as a condition to the conflict check
      check_for_conflicting_integrations { update_trs }

      save_trainee

      enqueue_jobs

      true
    end

  private

    attr_reader :trainee, :params, :update_trs, :dqt_enabled, :trs_enabled

    def save_trainee
      if params.present?
        trainee.update!(params)
      else
        trainee.save!
      end
    end

    def enqueue_jobs
      return unless valid_for_update?

      if update_trs && trs_enabled
        Trs::UpdateTraineeJob.perform_later(trainee)
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      end
    end

    def valid_for_update?
      trainee.trn.present? && !trainee.withdrawn? && !trainee.awarded?
    end
  end
end

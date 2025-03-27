# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    class ConflictingIntegrationsError < StandardError; end

    def initialize(trainee:, params: {}, update_dqt: true)
      @trainee = trainee
      @params = params
      @update_dqt = update_dqt
      @dqt_enabled = FeatureService.enabled?(:integrate_with_dqt)
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      check_for_conflicting_integrations

      save_trainee

      enqueue_jobs

      true
    end

  private

    attr_reader :trainee, :params, :update_dqt, :dqt_enabled, :trs_enabled

    def check_for_conflicting_integrations
      if update_dqt && dqt_enabled && trs_enabled
        raise(ConflictingIntegrationsError, "Both DQT and TRS integrations are enabled. Only one should be active at a time.")
      end
    end

    def save_trainee
      if params.present?
        trainee.update!(params)
      else
        trainee.save!
      end
    end

    def enqueue_jobs
      return unless valid_for_update?

      if update_dqt
        if trs_enabled
          Trs::UpdateTraineeJob.perform_later(trainee)
        elsif dqt_enabled
          Dqt::UpdateTraineeJob.perform_later(trainee)
        end
      end
    end

    def valid_for_update?
      trainee.trn.present? && !trainee.withdrawn? && !trainee.awarded?
    end
  end
end

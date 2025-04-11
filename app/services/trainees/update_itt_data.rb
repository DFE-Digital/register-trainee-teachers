# frozen_string_literal: true

module Trainees
  class UpdateIttData
    include ServicePattern

    class ConflictingIntegrationsError < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @dqt_enabled = FeatureService.enabled?(:integrate_with_dqt)
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      return if trainee.trn.blank?

      check_for_conflicting_integrations

      if trs_enabled
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      elsif dqt_enabled
        Dqt::RecommendForAwardJob.perform_later(trainee) if trainee.recommended_for_award?
        Dqt::WithdrawTraineeJob.perform_later(trainee) if trainee.withdrawn?
        Dqt::UpdateTraineeJob.perform_later(trainee) if trainee_updatable?
      end
    end

  private

    attr_reader :trainee, :dqt_enabled, :trs_enabled

    def check_for_conflicting_integrations
      if dqt_enabled && trs_enabled
        raise(ConflictingIntegrationsError, "Both DQT and TRS integrations are enabled. Only one should be active at a time.")
      end
    end

    def trainee_updatable?
      %w[submitted_for_trn trn_received deferred].include?(trainee.state)
    end
  end
end

# frozen_string_literal: true

module Trainees
  class UpdateIttDataInTra
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      return if trainee.trn.blank?

      if trs_enabled
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      end
    end

  private

    attr_reader :trainee, :trs_enabled

    def trainee_updatable?
      %w[submitted_for_trn trn_received deferred].include?(trainee.state)
    end
  end
end

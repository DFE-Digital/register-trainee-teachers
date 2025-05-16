# frozen_string_literal: true

module Trs
  class UpdateProfessionalStatus
    include ServicePattern

    class ProfessionalStatusUpdateMissingTrn < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @payload = Params::ProfessionalStatus.new(trainee:)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_trs)

      if trainee.trn.blank?
        raise_professional_status_update_missing_trn_message
      end

      Rails.logger.info("Updating professional status for trainee #{trainee.id} with TRN #{trainee.trn}\nPayload:\n#{payload.to_json}")

      update_professional_status
    end

  private

    attr_reader :trainee, :payload

    def raise_professional_status_update_missing_trn_message
      raise(
        ProfessionalStatusUpdateMissingTrn,
        <<~TEXT,
          Cannot update professional status on TRS without a TRN
          slug: #{trainee.slug}
          id: #{trainee.id}
          #{Settings.base_url}/trainees/#{trainee.slug}
        TEXT
      )
    end

    def update_professional_status
      Client.put("/v3/persons/#{trainee.trn}/professional-statuses/#{trainee.slug}", body: payload.to_json)
    end
  end
end

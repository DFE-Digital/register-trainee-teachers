# frozen_string_literal: true

module Trs
  class UpdateProfessionalStatus
    include ServicePattern

    class ProfessionalStatusUpdateError < StandardError; end
    class ProfessionalStatusUpdateMissingTrn < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @payload = Params::ProfessionalStatus.new(trainee:)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_trs)

      if trainee.trn.blank?
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

      update_professional_status
      nil
    end

  private

    attr_reader :trainee, :payload

    def update_professional_status
      Client.put("/v3/persons/#{trainee.trn}/professional-statuses/#{trainee.slug}", body: payload.to_json)
    end
  end
end

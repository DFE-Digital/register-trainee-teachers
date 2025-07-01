# frozen_string_literal: true

module Trs
  class UpdateProfessionalStatus
    include ServicePattern

    class ProfessionalStatusUpdateMissingTrn < StandardError; end
    class ProfessionalStatusUpdateError < StandardError; end

    # Error codes that indicate specific TRS states that we can ignore:
    # 10052: Route to professional status already awarded
    IGNORABLE_ERROR_CODES = [10052].freeze

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
      Client.put("/v3/persons/#{trainee.trn}/routes-to-professional-statuses/#{trainee.slug}", body: payload.to_json)
    rescue Client::HttpError => e
      # If the error indicates the status is already awarded, consider this a success
      if ignorable_error?(e.message)
        Rails.logger.info("Ignoring TRS error for trainee #{trainee.id}: #{e.message}")
        return {}
      end

      raise(ProfessionalStatusUpdateError, "Error updating professional status: #{e.message}")
    end

    def ignorable_error?(error_message)
      error_code_pattern = /"errorCode":(#{IGNORABLE_ERROR_CODES.join('|')})/
      error_message.match?(error_code_pattern)
    end
  end
end

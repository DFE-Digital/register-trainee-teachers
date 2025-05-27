# frozen_string_literal: true

module Trs
  class UpdatePersonalData
    include ServicePattern

    class PersonUpdateMissingTrn < StandardError; end
    class PersonUpdateError < StandardError; end

    # Error codes that indicate TRS disallows PII updates to the record.
    # When these errors occur, we can consider the update a successful completion.
    # 10041: Updates to PII data is not permitted.
    # 10042: Updates to PII data is not permitted. Person has QTS.
    IGNORABLE_ERROR_CODES = [10041, 10042].freeze

    def initialize(trainee:)
      @trainee = trainee
      @payload = Params::PersonalData.new(trainee:)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_trs)
      return unless valid_update_state?

      if trainee.trn.blank?
        raise(
          PersonUpdateMissingTrn,
          <<~TEXT,
            Cannot update person personal data on TRS without a TRN
            slug: #{trainee.slug}
            id: #{trainee.id}
            #{Settings.base_url}/trainees/#{trainee.slug}
          TEXT
        )
      end

      update_personal_data
    end

  private

    attr_reader :trainee, :payload

    def valid_update_state?
      ::CodeSets::Trs.valid_for_update?(trainee.state)
    end

    def update_personal_data
      Client.put("/v3/persons/#{trainee.trn}", body: payload.to_json)
    rescue Client::HttpError => e
      return if ignorable_error?(e.message)

      raise(PersonUpdateError, "Error updating personal data: #{e.message}")
    end

    def ignorable_error?(error_message)
      error_code_pattern = /"errorCode":(#{IGNORABLE_ERROR_CODES.join('|')})/
      error_message.match?(error_code_pattern)
    end
  end
end

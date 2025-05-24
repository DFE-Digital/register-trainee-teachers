# frozen_string_literal: true

module Trs
  class UpdatePersonalData
    include ServicePattern

    class PersonUpdateMissingTrn < StandardError; end
    class PersonUpdateError < StandardError; end

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
      # When error code is 10042, the person has QTS and updates to PII are not permitted
      # We can consider this a successful completion and just return
      return if e.message.include?('"errorCode":10042')

      raise(PersonUpdateError, "Error updating personal data: #{e.message}")
    end
  end
end

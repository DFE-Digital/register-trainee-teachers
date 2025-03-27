# frozen_string_literal: true

module Trs
  class UpdatePersonPii
    include ServicePattern

    class PersonPiiUpdateError < StandardError; end
    class PersonUpdateMissingTrn < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @payload = Params::PersonPii.new(trainee:)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_trs)

      # Only update if trainee is in a valid state
      return unless valid_update_state?

      if trainee.trn.blank?
        raise(
          PersonUpdateMissingTrn,
          <<~TEXT,
            Cannot update person PII on TRS without a TRN
            slug: #{trainee.slug}
            id: #{trainee.id}
            #{Settings.base_url}/trainees/#{trainee.slug}
          TEXT
        )
      end

      # No longer try to catch specific errors
      update_pii
    end

  private

    attr_reader :trainee, :payload

    def valid_update_state?
      !Config::INVALID_UPDATE_STATES.include?(trainee.state)
    end

    def update_pii
      Client.put("/v3/persons/#{trainee.trn}", body: payload.to_json)
    end
  end
end

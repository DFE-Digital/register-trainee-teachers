# frozen_string_literal: true

module Dqt
  class TraineeUpdate
    include ServicePattern

    class TraineeUpdateMissingTrn < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @payload = Params::Update.new(trainee:)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)
      return if trainee.submitted_for_trn?

      if trainee.trn.blank?
        raise(
          TraineeUpdateMissingTrn,
          <<~TEXT
            Cannot update trainee on DQT without a trn
            slug: #{trainee.slug}
            id: #{trainee.id}
            #{Settings.base_url}/trainees/#{trainee.slug}
          TEXT
        )
      end 

      dqt_update(
        "/v2/teachers/update/#{trainee.trn}?slugId=#{trainee.slug}&birthDate=#{trainee.date_of_birth.iso8601}",
        payload,
      )
    end

  private

    attr_reader :trainee, :payload

    def dqt_update(path, body)
      Client.patch(path, body: body.to_json)
    end
  end
end

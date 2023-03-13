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

      raise(TraineeUpdateMissingTrn, "Cannot update trainee on DQT without a trn (id: #{trainee.id})") if trainee.trn.blank?

      dqt_update("/v2/teachers/update/#{trainee.trn}?birthDate=#{trainee.date_of_birth.iso8601}", payload)
    end

  private

    attr_reader :trainee, :payload

    def dqt_update(path, body)
      Client.patch(path, body: body.to_json)
    end
  end
end

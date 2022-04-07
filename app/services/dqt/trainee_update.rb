# frozen_string_literal: true

module Dqt
  class TraineeUpdate
    include ServicePattern

    def initialize(trainee:)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @trainee = trainee
      @payload = Params::TraineeRequest.new(trainee: trainee)
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)

      dqt_update("/v2/teachers/update/#{trainee.trn}?birthDate=#{trainee.date_of_birth.iso8601}", payload)
    end

  private

    attr_reader :trainee, :payload

    def dqt_update(path, body)
      Client.patch(path, body: body.to_json)
    end
  end
end

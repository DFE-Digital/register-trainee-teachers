# frozen_string_literal: true

module Dqt
  class WithdrawTrainee
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)

      dqt_update
    end

  private

    attr_reader :trainee

    def dqt_update
      Client.patch(path, body: params.to_json)
    end

    def path
      "/v2/teachers/#{trainee.trn}/itt-outcome?birthDate=#{trainee.date_of_birth.iso8601}"
    end

    def params
      @params ||= Params::Withdrawal.new(trainee: @trainee)
    end
  end
end

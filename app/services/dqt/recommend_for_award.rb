# frozen_string_literal: true

module Dqt
  class RecommendForAward
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)

      response["qtsDate"]
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.put(path, body: params.to_json)
    end

    def path
      @path ||= "/v2/teachers/#{trainee.trn}/itt-outcome?birthDate=#{trainee.date_of_birth.iso8601}"
    end

    def params
      @params ||= Params::Award.new(trainee: trainee)
    end
  end
end

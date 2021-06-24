# frozen_string_literal: true

module Dttp
  class UpdateDormancy
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      response
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.patch(
        "/dfe_dormantperiods(#{trainee.dormancy_dttp_id})",
        body: params.to_json,
      )
    end

    def params
      @params ||= Params::Dormancy.new(trainee: trainee)
    end
  end
end

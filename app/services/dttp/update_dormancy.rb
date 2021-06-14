# frozen_string_literal: true

module Dttp
  class UpdateDormancy
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      response = Client.patch(
        "/dfe_dormantperiods(#{trainee.dormancy_dttp_id})",
        body: params.to_json,
      )

      if response.code != 204
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      response
    end

  private

    def params
      @params ||= Params::Dormancy.new(trainee: trainee)
    end
  end
end

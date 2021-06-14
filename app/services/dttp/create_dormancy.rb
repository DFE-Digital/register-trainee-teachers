# frozen_string_literal: true

module Dttp
  class CreateDormancy
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      response = Client.post("/dfe_dormantperiods", body: params.to_json)

      if response.code != 204
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      trainee.update!(dormancy_dttp_id: Dttp::OdataParser.entity_id(trainee.id, response))
    end

  private

    def params
      @params ||= Params::Dormancy.new(trainee: trainee)
    end
  end
end

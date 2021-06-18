# frozen_string_literal: true

module Dttp
  class CreateDormancy
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      trainee.update!(dormancy_dttp_id: Dttp::OdataParser.entity_id(trainee.id, response)) if response.success?
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.post("/dfe_dormantperiods", body: params.to_json)
    end

    def params
      @params ||= Params::Dormancy.new(trainee: trainee)
    end
  end
end

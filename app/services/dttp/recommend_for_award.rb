# frozen_string_literal: true

module Dttp
  class RecommendForAward
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      response = Client.patch(
        "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        body: params.to_json,
      )

      if response.code != 204
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      CreateOrUpdateConsistencyCheckJob.perform_later(trainee)
      response
    end

  private

    def params
      @params ||= Params::PlacementOutcomes::Qts.new(trainee: trainee)
    end
  end
end

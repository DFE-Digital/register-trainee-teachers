# frozen_string_literal: true

module Dttp
  class WithdrawTrainee
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      CreateOrUpdateConsistencyCheckJob.perform_later(trainee) if response.success?
      response
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.patch(
        "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        body: params.to_json,
      )
    end

    def params
      @params ||= Params::PlacementOutcomes::Withdrawn.new(trainee: trainee)
    end
  end
end

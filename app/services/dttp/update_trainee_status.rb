# frozen_string_literal: true

module Dttp
  class UpdateTraineeStatus
    include ServicePattern

    ENDPOINTS = {
      contact: "/contacts",
      placement_assignment: "/dfe_placementassignments",
    }.freeze

    CONTACT_ENTITY_TYPE = :contact
    PLACEMENT_ASSIGNMENT_ENTITY_TYPE = :placement_assignment

    def initialize(status:, entity_type:, trainee:)
      @trainee = trainee
      @entity_type = entity_type
      @path = ENDPOINTS[entity_type] + "(#{entity_id})"
      @params = Dttp::Params::Status.new(status: status)
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      CreateOrUpdateConsistencyCheckJob.perform_later(trainee) if response.success?
    end

  private

    attr_reader :path, :params, :trainee, :entity_type

    def response
      @response ||= Client.patch(path, body: params.to_json)
    end

    def entity_id
      return trainee.dttp_id if entity_type == CONTACT_ENTITY_TYPE

      trainee.placement_assignment_dttp_id
    end
  end
end

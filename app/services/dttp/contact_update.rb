# frozen_string_literal: true

module Dttp
  class ContactUpdate
    include ServicePattern

    def initialize(trainee:)
      return unless FeatureService.enabled?(:persist_to_dttp)

      @trainee = trainee
      @contact_payload = Params::Contact.new(trainee)
      @placement_assignment_payload = Params::PlacementAssignment.new(trainee)
    end

    def call
      return unless FeatureService.enabled?(:persist_to_dttp)

      dttp_update("/contacts(#{trainee.dttp_id})", contact_payload)

      dttp_update("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
                  placement_assignment_payload)

      trainee.update!(dttp_update_sha: trainee.sha)
      CreateOrUpdateConsistencyCheckJob.perform_later(trainee)
    end

  private

    attr_reader :trainee, :contact_payload, :placement_assignment_payload

    def dttp_update(path, body)
      Client.patch(path, body: body.to_json)
    end
  end
end

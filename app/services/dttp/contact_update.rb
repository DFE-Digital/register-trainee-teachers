# frozen_string_literal: true

module Dttp
  class ContactUpdate
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
      @contact_payload = Params::Contact.new(trainee)
      @placement_assignment_payload = Params::PlacementAssignment.new(trainee)
    end

    def call
      dttp_update("/contacts(#{trainee.dttp_id})", @contact_payload)

      dttp_update("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
                  @placement_assignment_payload)

      trainee.update!(dttp_update_sha: trainee.sha)
    end

  private

    def dttp_update(path, body)
      response = Client.patch(path, body: body.to_json)
      raise Error, response.body if response.code != 204
    end
  end
end

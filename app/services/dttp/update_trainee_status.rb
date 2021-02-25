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

    class Error < StandardError; end

    def initialize(status:, entity_id:, entity_type:)
      @path = ENDPOINTS[entity_type] + "(#{entity_id})"
      @params = Dttp::Params::Status.new(status: status)
    end

    def call
      response = Client.patch(path, body: params.to_json)
      if response.code != 204
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end
    end

  private

    attr_reader :path, :params
  end
end

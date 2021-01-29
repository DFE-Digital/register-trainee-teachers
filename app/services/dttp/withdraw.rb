# frozen_string_literal: true

module Dttp
  class Withdraw
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      dttp_update(
        "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        Dttp::Params::Status.new(status: DttpStatuses::REJECTED),
      )
    end

  private

    def dttp_update(path, body)
      response = Client.patch(path, body: body.to_json)
      raise Error, response.body if response.code != 204
    end
  end
end

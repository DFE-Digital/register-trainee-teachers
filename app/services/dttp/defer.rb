# frozen_string_literal: true

module Dttp
  class Defer
    include ServicePattern
    include Mappable

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      body = { "dfe_TraineeStatusId@odata.bind" => "/dfe_traineestatuses(#{dttp_status_id(DttpStatuses::DEFERRED)})" }

      dttp_update("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})", body)

      trainee.defer!
    end

  private

    def dttp_update(path, body)
      response = Client.patch(path, body: body.to_json)
      raise Error, response.body if response.code != 204
    end
  end
end

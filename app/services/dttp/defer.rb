# frozen_string_literal: true

module Dttp
  class Defer
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      body = { "dfe_TraineeStatusId@odata.bind" => "/dfe_traineestatuses(1d5af972-9e1b-e711-80c7-0050568902d3)" }

      dttp_update("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})", body)
    end

  private

    def dttp_update(path, body)
      response = Client.patch(path, body: body.to_json)
      raise Error, response.body if response.code != 204
    end
  end
end

# frozen_string_literal: true

module Dttp
  class RetrieveQts
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      response = Client.get("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})?$select=dfe_qtsawardflag")
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)["dfe_qtsawardflag"]
    end
  end
end

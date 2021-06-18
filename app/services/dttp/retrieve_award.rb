# frozen_string_literal: true

module Dttp
  class RetrieveAward
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      JSON(response.body)["dfe_qtsawardflag"]
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.get("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})?$select=dfe_qtsawardflag")
    end
  end
end

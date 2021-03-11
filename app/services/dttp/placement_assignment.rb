# frozen_string_literal: true

module Dttp
  class PlacementAssignment
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :trainee

    PLACEMENT_ASSIGNMENT_FIELDS = %w[
      dfe_programmestartdate
      dfe_programmeenddate
      dfe_placementassignmentid
      _dfe_providerid_value
    ].freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      response = Client.get("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})?$select=#{PLACEMENT_ASSIGNMENT_FIELDS.join(',')}")

      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body).slice(*PLACEMENT_ASSIGNMENT_FIELDS)
    end
  end
end

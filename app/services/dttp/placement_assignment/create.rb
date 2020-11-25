# frozen_string_literal: true

module Dttp
  module PlacementAssignment
    class Create
      class << self
        def call(**args)
          new(**args).call
        end
      end

      private_class_method :new

      attr_reader :trainee

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        response = Client.post("/dfe_placementassignments", body: trainee.placement_assignment_params.to_json)
        OdataParser.entity_id(trainee.id, response)
      end
    end
  end
end

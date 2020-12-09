# frozen_string_literal: true

module Dttp
  class BatchCreate
    include ServicePattern

    attr_reader :trainee, :batch_request

    def initialize(trainee:)
      @trainee = Dttp::TraineePresenter.new(trainee: trainee)
      @batch_request = BatchRequest.new
    end

    def call
      contact_change_set_id = batch_request.add_change_set(entity: "contacts",
                                                           payload: trainee.contact_params.to_json)

      batch_request.add_change_set(entity: "dfe_placementassignments",
                                   payload: trainee.placement_assignment_params(contact_change_set_id).to_json)

      batch_response = batch_request.submit

      entity_ids = OdataParser.entity_ids(batch_response: batch_response)
      trainee.update!(dttp_id: entity_ids["contacts"])
      entity_ids
    end
  end
end

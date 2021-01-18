# frozen_string_literal: true

module Dttp
  class ContactUpdate
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee, :trainee_creator_dttp_id, :batch_request

    def initialize(trainee:, trainee_creator_dttp_id:)
      @trainee = trainee
      @trainee_presenter = Dttp::TraineePresenter.new(trainee: trainee)
      @trainee_creator_dttp_id = trainee_creator_dttp_id
    end

    def call
      dttp_update("/contacts(#{trainee.dttp_id})",
                  @trainee_presenter.contact_update_params(trainee_creator_dttp_id).to_json)

      dttp_update("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
                  @trainee_presenter.placement_assignment_update_params.to_json)
    end

  private

    def dttp_update(path, body)
      response = Client.patch(path, body: body)
      raise Error, response.body if response.code != 204
    end
  end
end

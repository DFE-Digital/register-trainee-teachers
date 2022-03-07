# frozen_string_literal: true

module Dqt
  class RegisterForTrn
    include ServicePattern

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_dqt)

      submit_trn_request
      update_trainee
      trn_request
    end

  private

    def trn_request
      @trn_request ||= TrnRequest.new(trainee: trainee, request_id: SecureRandom.uuid)
    end

    def submit_trn_request
      path = "/v2/trn-requests/#{trn_request.request_id}"
      body = Dqt::Params::TrnRequest.new(trainee: trainee).to_json
      response = Client.put(path, body: body)
      trn_request.response = response
      trn_request.requested!
    end

    def update_trainee
      trainee.submit_for_trn! if trainee.can_submit_for_trn?
    end
  end
end

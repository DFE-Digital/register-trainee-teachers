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
      @trn_request ||= Trs::TrnRequest.create_with(request_id: SecureRandom.uuid)
                                 .find_or_create_by!(trainee:)
    end

    def submit_trn_request
      path = "/v2/trn-requests/#{trn_request.request_id}"
      body = Dqt::Params::TrnRequest.new(trainee:).to_json
      response = Client.put(path, body:)
      trn_request.response = response
      trn_request.requested!
      Trainees::SetSlugSentAt.call(trainee:)
    rescue Client::HttpError => e
      # Sometimes we receive a 500 from DQT even though the TRN request is
      # eventually successful. Because of this, we still want to save the
      # trs_trn_request to the DB when it fails. This means we can kick off a
      # `RetrieveTrnJob` (which requires the request_id) in the future.
      trn_request.response = { error: e }
      trn_request.failed!
      Sentry.capture_exception(e)
    end

    def update_trainee
      trainee.submit_for_trn! if trainee.can_submit_for_trn?
    end
  end
end

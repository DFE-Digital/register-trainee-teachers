# frozen_string_literal: true

module Trs
  class RegisterForTrn
    include ServicePattern

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return unless FeatureService.enabled?(:integrate_with_trs)

      submit_trn_request
      trainee.submit_for_trn! if trainee.can_submit_for_trn?
      trn_request
    end

  private

    def submit_trn_request
      trn_request.response = response
      trn_request.requested!
      Trainees::SetSlugSentAt.call(trainee:)
    rescue Client::HttpError => e
      trn_request.response = { error: e }
      trn_request.failed!
      Sentry.capture_exception(e)
    end

    def trn_request
      @trn_request ||=
        ::Trs::TrnRequest.create_with(request_id:)
                         .find_or_create_by!(trainee:)
    end

    def response
      @response ||= Client.post("/v3/trn-requests/", body:)
    end

    def body
      @body ||= Params::TrnRequest.new(trainee:, request_id:).to_json
    end

    def request_id
      @request_id ||= SecureRandom.uuid
    end
  end
end

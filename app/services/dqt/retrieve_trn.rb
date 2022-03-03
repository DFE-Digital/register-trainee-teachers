# frozen_string_literal: true

module Dqt
  class RetrieveTrn
    include ServicePattern

    def initialize(trn_request:)
      @trn_request = trn_request
    end

    def call
      response["trn"]
    end

  private

    attr_reader :trn_request

    def response
      @response ||= Client.get("/v2/trn-requests/#{trn_request.request_id}")
    end
  end
end

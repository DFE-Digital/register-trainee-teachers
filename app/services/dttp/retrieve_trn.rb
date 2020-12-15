# frozen_string_literal: true

module Dttp
  class RetrieveTrn
    include ServicePattern

    class HttpError < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      response = Client.get("/contacts(#{trainee.dttp_id})?$select=dfe_trn")
      raise HttpError, response.body unless response.code == 200

      JSON(response.body)["dfe_trn"]
    end
  end
end

# frozen_string_literal: true

module Dttp
  class RetrieveTrn
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      JSON(response.body)["dfe_trn"]
    end

  private

    attr_reader :trainee

    def response
      @response ||= Client.get("/contacts(#{trainee.dttp_id})?$select=dfe_trn")
    end
  end
end

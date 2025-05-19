# frozen_string_literal: true

module Trs
  class RetrieveTeacher
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      Client.get("/v3/persons/#{trainee.trn}")
    end

  private

    attr_reader :trainee
  end
end

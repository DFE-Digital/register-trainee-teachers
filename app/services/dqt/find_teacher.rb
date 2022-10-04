# frozen_string_literal: true

module Dqt
  class FindTeacher
    include ServicePattern

    class Error < StandardError; end

    delegate :first_names, :last_name, :date_of_birth, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      if teachers.count > 1
        raise(Error, "Multiple teachers found with firstName: #{first_names}, lastName: #{last_name}, dateOfBirth: #{date_of_birth}")
      end

      teachers.first
    end

    attr_reader :trainee

  private

    def teachers
      Client.get("/v2/teachers/find?#{params.to_query}")["results"]
    end

    def params
      {
        firstName: first_names,
        lastName: last_name,
        dateOfBirth: date_of_birth.iso8601,
      }
    end
  end
end

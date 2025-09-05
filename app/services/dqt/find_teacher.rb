# frozen_string_literal: true

module Dqt
  class FindTeacher
    include ServicePattern

    class Error < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      if teachers.empty?
        raise(Error, "No teachers found in DQT for trainee #{trainee.id}")
      end

      if teachers.many?
        raise(Error, "Multiple teachers found in DQT for trainee #{trainee.id}")
      end

      teachers.first
    end

  private

    attr_reader :trainee

    def teachers
      @teachers ||= Client.get("/v2/teachers/find?#{params.to_query}")["results"]
    end

    # The DQT API requires at least three data items to return a teacher.
    # `firstName` and `lastName` count as one data item.
    def params
      {
        firstName: trainee.first_names.split.first,
        lastName: trainee.last_name,
        dateOfBirth: trainee.date_of_birth.iso8601,
        emailAddress: trainee.email,
      }
    end
  end
end

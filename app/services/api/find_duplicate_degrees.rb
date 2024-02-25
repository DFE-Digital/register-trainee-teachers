# frozen_string_literal: true

module Api
  class FindDuplicateDegrees
    include ServicePattern
    include FindDuplicatesBase

    attr_accessor :trainee, :degree_attributes

    def initialize(trainee:, degree_attributes:)
      @trainee = trainee
      @degree_attributes = degree_attributes
    end

    def call
      find_duplicates(trainee)
    end

  private

    def find_duplicates(trainee)
      trainee.degrees.where(
        subject:,
      )
    end

    def subject
      degree_attributes.subject
    end
  end
end

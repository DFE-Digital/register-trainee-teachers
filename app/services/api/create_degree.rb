# frozen_string_literal: true

module Api
  class CreateDegree
    include ServicePattern

    attr_accessor :trainee, :degree_attributes, :current_version

    def initialize(trainee:, degree_attributes:, current_version:)
      @trainee = trainee
      @degree_attributes = degree_attributes
      @current_version = current_version
    end

    def call
      return validation_error_response(degree_attributes) unless degree_attributes.valid?

      degree = trainee.degrees.new(degree_attributes.attributes)
      unless degree.save
        return save_errors_response(degree)
      end

      success_response(degree)
    end

  private

    def save_errors_response(degree)
      { json: { errors: degree.errors.full_messages }, status: :unprocessable_entity }
    end

    def success_response(degree)
      {
        json: { data: DegreeSerializer.for(current_version).new(degree).as_hash },
        status: :created,
      }
    end

    def validation_error_response(degree_attributes)
      {
        json: { errors: degree_attributes.errors.full_messages },
        status: :unprocessable_entity,
      }
    end
  end
end

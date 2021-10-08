# frozen_string_literal: true

module Degrees
  class CreateFromApply
    include ServicePattern

    class ApplyApplicationNotFound < StandardError; end

    def initialize(trainee:)
      @degrees_form = DegreesForm.new(trainee)
      @application = trainee.apply_application
    end

    def call
      raise(ApplyApplicationNotFound, "Apply application not found against this trainee") if application.blank?

      create_degrees!
    end

  private

    attr_reader :application, :degrees_form

    def create_degrees!
      invalid_data = raw_degrees.map do |degree|
        degree_form = degrees_form.build_degree(::Degrees::MapFromApply.call(attributes: degree))

        [degree_form.to_param, degree_form.save_and_return_invalid_data!]
      end.to_h

      application.update!(degrees_invalid_data: invalid_data)
    end

    def raw_degrees
      @raw_degrees ||= application.application_attributes["qualifications"]["degrees"]
    end
  end
end

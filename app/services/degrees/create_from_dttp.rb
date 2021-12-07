# frozen_string_literal: true

module Degrees
  class CreateFromDttp
    include ServicePattern

    class DttpTraineeNotFound < StandardError; end

    def initialize(trainee:)
      @degrees_form = DegreesForm.new(trainee)
      @dttp_trainee = trainee.dttp_trainee
    end

    def call
      raise(DttpTraineeNotFound, "DTTP record not found against this trainee") if dttp_trainee.blank?

      create_degrees!
    end

  private

    attr_reader :dttp_trainee, :degrees_form

    def create_degrees!
      dttp_trainee.degree_qualifications.each do |dttp_degree|
        degree = degrees_form.build_degree(
          ::Degrees::MapFromDttp.call(dttp_degree: dttp_degree),
        )
        dttp_degree.processed! if degree.save!
      end
    end
  end
end

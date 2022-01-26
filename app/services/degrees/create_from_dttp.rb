# frozen_string_literal: true

module Degrees
  class CreateFromDttp
    include ServicePattern

    class DttpTraineeNotFound < StandardError; end

    def initialize(trainee:)
      @trainee = trainee
      @dttp_trainee = trainee.dttp_trainee
    end

    def call
      raise(DttpTraineeNotFound, "DTTP record not found against this trainee") if dttp_trainee.blank?

      create_degrees!
    end

  private

    attr_reader :dttp_trainee, :trainee

    def create_degrees!
      dttp_trainee.degree_qualifications.each do |dttp_degree|
        attrs = ::Degrees::MapFromDttp.call(dttp_degree: dttp_degree, dttp_trainee: dttp_trainee)
        next unless attrs

        trainee.degrees.build(attrs)

        if trainee.save
          dttp_degree.imported!
        else
          dttp_degree.non_importable_invalid_data!
        end
      end
    end
  end
end

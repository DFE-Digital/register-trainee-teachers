# frozen_string_literal: true

module Dttp
  module Parsers
    class TrainingInitiative
      class << self
        def to_attributes(training_initiatives:)
          training_initiatives.map do |training_initiative|
            {
              dttp_id: training_initiative["dfe_initiativeid"],
              response: training_initiative,
            }
          end
        end
      end
    end
  end
end

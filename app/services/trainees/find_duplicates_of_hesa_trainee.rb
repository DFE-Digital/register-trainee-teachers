# frozen_string_literal: true

module Trainees
  class FindDuplicatesOfHesaTrainee
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      potential_duplicates.select { |duplicate_trainee| confirmed_duplicate?(duplicate_trainee) }
    end

  private

    attr_reader :trainee

    def potential_duplicates
      Trainee.potential_duplicates_of(trainee)
    end

    def confirmed_duplicate?(duplicate_trainee)
      at_least_one_match_identifying_attribute?(duplicate_trainee)
    end

    def at_least_one_match_identifying_attribute?(duplicate_trainee)
      matching_first_name?(duplicate_trainee) ||
        matching_email?(duplicate_trainee)
    end

    def matching_first_name?(duplicate_trainee)
      extract_first_name(duplicate_trainee.first_names) ==
        extract_first_name(trainee.first_names)
    end

    def matching_email?(duplicate_trainee)
      normalise_name(duplicate_trainee.email) == normalise_name(trainee.email)
    end

    def normalise_name(name)
      name&.strip&.downcase
    end

    def normalise_and_remove_punctuation(name)
      normalise_name(name)&.gsub(/[^a-z ]/, "")
    end

    def extract_first_name(names)
      normalise_and_remove_punctuation(names)&.partition(" ")&.first
    end
  end
end

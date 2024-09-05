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
      trainee.provider.trainees.not_withdrawn.or(Trainee.not_awarded)
        .where(date_of_birth: trainee.date_of_birth)
        .where("last_name ILIKE ?", trainee.last_name)
        .where("id != ?", trainee.id)
    end

    def confirmed_duplicate?(duplicate_trainee)
      matching_recruitment_cycle_year?(duplicate_trainee) &&
      matching_course_route?(duplicate_trainee) &&
      at_least_one_match_identifying_attribute?(duplicate_trainee)
    end

    def matching_recruitment_cycle_year?(duplicate_trainee)
      duplicate_trainee.start_academic_cycle&.start_date&.year == trainee.start_academic_cycle&.start_date&.year
    end

    def matching_course_route?(duplicate_trainee)
      duplicate_trainee.training_route == trainee.training_route
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

# frozen_string_literal: true

module Api
  class FindDuplicateTrainees
    include ServicePattern

    attr_accessor :provider, :attributes

    def initialize(provider:, attributes:)
      @provider = provider
      @attributes = attributes
    end

    def call
      potential_duplicates.select { |trainee| confirmed_duplicate?(trainee) }
    end

  private

    # attr_reader :application_record, :raw_trainee, :raw_course, :course
  
    def date_of_birth
      attributes.date_of_birth
    end
  
    def last_name
      attributes.last_name
    end

    def potential_duplicates
      provider.trainees.not_withdrawn.or(Trainee.not_awarded)
        .where(date_of_birth: date_of_birth)
        .where("last_name ILIKE ?", last_name)
    end

    def confirmed_duplicate?(trainee)
      matching_recruitment_cycle_year?(trainee) &&
      matching_course_route?(trainee) &&
      at_least_one_match_identifying_attribute?(trainee)
    end

    def matching_recruitment_cycle_year?(trainee)
      trainee.start_academic_cycle&.start_date&.year == raw_course["recruitment_cycle_year"]
    end

    def matching_course_route?(trainee)
      course.present? && trainee.training_route == course["route"]
    end

    def at_least_one_match_identifying_attribute?(trainee)
      matching_first_name?(trainee) ||
        matching_email?(trainee)
    end

    def matching_first_name?(trainee)
      extract_first_name(trainee.first_names) ==
        extract_first_name(raw_trainee["first_name"])
    end

    def matching_email?(trainee)
      normalise_name(trainee.email) == normalise_name(raw_trainee["email"])
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

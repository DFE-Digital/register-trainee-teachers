# frozen_string_literal: true

module Trainees
  class FindDuplicates
    include ServicePattern

    def initialize(application_record:)
      @application_record = application_record
      @raw_course = application_record.application.dig("attributes", "course")
      @course = application_record.provider.courses.find_by(uuid: @raw_course["course_uuid"])
      @raw_trainee = application_record.application.dig("attributes", "candidate")
    end

    def call
      potential_duplicates.select { |trainee| confirmed_duplicate?(trainee) }
    end

  private

    attr_reader :application_record, :raw_trainee, :raw_course, :course

    def potential_duplicates
      application_record.provider.trainees.not_withdrawn.or(Trainee.not_awarded)
        .where(date_of_birth: raw_trainee["date_of_birth"])
        .where("last_name ILIKE ?", raw_trainee["last_name"])
    end

    def confirmed_duplicate?(trainee)
      matching_recruitment_cycle_year?(trainee) &&
      matching_qualification_type?(trainee) &&
      at_least_one_match_identifying_attribute?(trainee)
    end

    def matching_recruitment_cycle_year?(trainee)
      trainee.start_academic_cycle&.start_date&.year == raw_course["recruitment_cycle_year"]
    end

    def matching_qualification_type?(trainee)
      trainee.training_route == course["route"]
    end

    def at_least_one_match_identifying_attribute?(trainee)
      matching_first_name?(trainee) ||
        matching_email?(trainee)
    end

    def matching_first_name?(trainee)
      trainee.first_names&.strip&.downcase&.gsub(/[^a-z ]/, "")&.partition(" ")&.first ==
        raw_trainee["first_name"]&.strip&.downcase&.gsub(/[^a-z ]/, "")&.partition(" ")&.first
    end

    def matching_email?(trainee)
      trainee.email&.strip&.downcase == raw_trainee["email"]&.strip&.downcase
    end
  end
end

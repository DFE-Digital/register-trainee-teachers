# frozen_string_literal: true

module Trainees
  class CreateFromApply
    include ServicePattern

    class MissingCourseError < StandardError; end

    def initialize(application:)
      @application = application
      @raw_course = application.application_attributes["course"]
      @course = application.provider.courses.find_by(uuid: @raw_course["course_uuid"])
      @raw_trainee = application.application_attributes["candidate"]
      @raw_contact_details = application.application_attributes["contact_details"]
      @study_mode = TRAINEE_STUDY_MODE_ENUMS[@raw_course["study_mode"]]
      @disabilities = Disability.where(name: disability_names)
      @trainee = Trainee.new(mapped_attributes)
      @personal_details_form = PersonalDetailsForm.new(trainee, params: { nationality_names: nationality_names })
    end

    def call
      if trainee_already_exists?
        application.non_importable_duplicate!
        return
      end

      raise(MissingCourseError, "Cannot find course with uuid: #{@raw_course['course_uuid']}") if course.nil? # Courses can be missing in non-prod environments

      trainee.save!
      save_personal_details!
      create_degrees!
      application.imported!

      trainee
    end

  private

    attr_reader :application,
                :trainee,
                :course,
                :raw_trainee,
                :raw_contact_details,
                :study_mode,
                :disabilities,
                :personal_details_form

    def mapped_attributes
      {
        apply_application: application,
        provider: application.provider,
        first_names: raw_trainee["first_name"],
        last_name: raw_trainee["last_name"],
        date_of_birth: raw_trainee["date_of_birth"],
        gender: gender,
        ethnic_group: ethnic_group,
        diversity_disclosure: diversity_disclosure,
        disability_disclosure: disability_disclosure,
        email: raw_contact_details["email"],
        course_code: course&.code,
        course_min_age: course&.min_age,
        course_max_age: course&.max_age,
        training_route: course&.route,
        disabilities: disabilities,
        study_mode: study_mode,
      }.merge(address).merge(ethnic_background_attributes)
    end

    def create_degrees!
      ::Degrees::CreateFromApply.call(trainee: trainee)
    end

    def save_personal_details!
      personal_details_form.save!
      verify_nationalities_data!
    end

    def verify_nationalities_data!
      invalid_nationalities = raw_trainee["nationality"] - ApplyApi::CodeSets::Nationalities::MAPPING.keys

      return if invalid_nationalities.blank?

      Sentry.capture_message("Cannot map nationality from ApplyApplication id: #{application.id}, code: #{invalid_nationalities.join(', ')}")
    end

    def address
      raw_contact_details["country"] == "GB" ? uk_address : international_address
    end

    def international_address
      {
        international_address: raw_contact_details["address_line1"],
        locale_code: Trainee.locale_codes[:non_uk],
      }
    end

    def uk_address
      {
        address_line_one: raw_contact_details["address_line1"],
        address_line_two: raw_contact_details["address_line2"],
        town_city: raw_contact_details["address_line3"],
        postcode: raw_contact_details["postcode"],
        locale_code: Trainee.locale_codes[:uk],
      }
    end

    def gender
      ApplyApi::CodeSets::Genders::MAPPING[raw_trainee["gender"]] || Trainee.genders[:gender_not_provided]
    end

    def ethnic_group
      ApplyApi::CodeSets::Ethnicities::MAPPING.fetch(raw_trainee["ethnic_group"],
                                                     Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    end

    def diversity_disclosure
      return Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] if diversity_disclosed?

      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end

    def disability_disclosure
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] if disability_disclosed? && disabilities.present?
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] if disability_disclosed? && disabilities.blank?

      Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
    end

    def diversity_disclosed?
      raw_trainee.slice("disabilities", "ethnic_group", "ethnic_background").values.any?(&:present?)
    end

    def disability_disclosed?
      raw_trainee["disability_disclosure"].present?
    end

    def disability_names
      raw_trainee["disabilities"].map { |disability| ApplyApi::CodeSets::Disabilities::MAPPING[disability] }
    end

    def nationality_names
      raw_trainee["nationality"].map do |nationality|
        ApplyApi::CodeSets::Nationalities::MAPPING[nationality]
      end
    end

    def trainee_already_exists?
      Trainee.exists?(first_names: raw_trainee["first_name"],
                      last_name: raw_trainee["last_name"],
                      date_of_birth: raw_trainee["date_of_birth"])
    end

    def ethnic_background_attributes
      ethnic_background = raw_trainee["ethnic_background"]

      return {} unless ethnic_group && ethnic_group != Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
      return {} unless ethnic_background

      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        { ethnic_background: ethnic_background }
      else
        {
          ethnic_background: Diversities::ANOTHER_BACKGROUND[ethnic_group],
          additional_ethnic_background: ethnic_background,
        }
      end
    end
  end
end

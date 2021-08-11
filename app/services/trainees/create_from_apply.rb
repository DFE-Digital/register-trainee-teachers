# frozen_string_literal: true

module Trainees
  class CreateFromApply
    include ServicePattern

    def initialize(application:)
      @application = application
    end

    def call
      trainee.save!
      save_personal_details!
      create_degrees!
      trainee
    end

  private

    attr_reader :application

    def trainee
      @trainee ||= Trainee.new(mapped_attributes)
    end

    def mapped_attributes
      {
        apply_application: application,
        provider: provider,
        first_names: raw_trainee["first_name"],
        last_name: raw_trainee["last_name"],
        date_of_birth: raw_trainee["date_of_birth"],
        gender: gender,
        ethnic_group: ethnic_group,
        ethnic_background: raw_trainee["ethnic_background"],
        diversity_disclosure: diversity_disclosure,
        email: raw_contact_details["email"],
        course_code: course&.code,
        training_route: course&.route,
        disabilities: disabilities,
        study_mode: study_mode,
      }.merge(address)
    end

    def personal_details_params
      {
        nationality_names: nationality_names,
      }
    end

    def create_degrees!
      ::Degrees::CreateFromApply.call(trainee: trainee)
    end

    def personal_details_form
      @personal_details_form ||= PersonalDetailsForm.new(trainee, params: personal_details_params)
    end

    def save_personal_details!
      personal_details_form.save!
      verify_nationalities_data!
    end

    def verify_nationalities_data!
      invalid_nationalities = raw_trainee["nationality"] - ApplyApi::CodeSets::Nationalities::MAPPING.keys

      return if invalid_nationalities.blank?

      Sentry.capture_message "Cannot map nationality from ApplyApplication id: #{application.id}, code: #{invalid_nationalities.join(', ')}"
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
      ApplyApi::CodeSets::Genders::MAPPING[raw_trainee["gender"]]
    end

    def ethnic_group
      ApplyApi::CodeSets::Ethnicities::MAPPING[raw_trainee["ethnic_group"]]
    end

    def diversity_disclosure
      return Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] if diversity_disclosed?

      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end

    def diversity_disclosed?
      raw_trainee.slice("disabilities", "ethnic_group", "ethnic_background").values.any?(&:present?)
    end

    def disabilities
      @disabilities ||= Disability.where(name: disability_names)
    end

    def disability_names
      raw_trainee["disabilities"].map { |disability| ApplyApi::CodeSets::Disabilities::MAPPING[disability] }
    end

    def nationality_names
      @nationality_names ||= raw_trainee["nationality"].map { |nationality| ApplyApi::CodeSets::Nationalities::MAPPING[nationality] }
    end

    def course
      @course ||= provider.courses.find_by(code: raw_course["course_code"])
    end

    def provider
      @provider ||= application.provider
    end

    def raw_trainee
      @raw_trainee ||= application.application_attributes["candidate"]
    end

    def raw_contact_details
      @raw_contact_details ||= application.application_attributes["contact_details"]
    end

    def raw_course
      @raw_course ||= application.application_attributes["course"]
    end

    def study_mode
      @study_mode ||= TRAINEE_STUDY_MODE_ENUMS[raw_course["study_mode"]]
    end
  end
end

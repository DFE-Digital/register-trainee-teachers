# frozen_string_literal: true

module Trainees
  class CreateFromApply
    include ServicePattern

    class MissingCourseError < StandardError; end

    def initialize(application:)
      @application_record = application
      @raw_course = application_record.application.dig("attributes", "course")
      @course = application_record.provider.courses.find_by(uuid: @raw_course["course_uuid"])
      @raw_trainee = application_record.application.dig("attributes", "candidate")
      @raw_contact_details = application_record.application.dig("attributes", "contact_details")
      @disability_uuids = raw_trainee["disabilities_and_health_conditions"]&.filter_map { |d| d["uuid"] } || []
      @study_mode = ::ReferenceData::STUDY_MODES.find(@raw_course["study_mode"])&.id
      @disabilities = Disability.where(uuid: disability_uuids)
      @trainee = Trainee.new(mapped_attributes)
      @personal_details_form = PersonalDetailsForm.new(trainee, params: { nationality_names: })
    end

    def call
      if trainee_already_exists?
        application_record.non_importable_duplicate!
        return
      end

      # Courses can be missing in non-prod environments
      raise(MissingCourseError, "Cannot find course with uuid: #{raw_course['course_uuid']}") if course.nil?

      trainee.save!
      save_other_disability_text!
      save_personal_details!
      create_degrees!
      application_record.imported!
      trainee
    end

  private

    attr_reader :application_record,
                :trainee,
                :course,
                :raw_course,
                :raw_trainee,
                :raw_contact_details,
                :study_mode,
                :disabilities,
                :personal_details_form,
                :disability_uuids

    def trainee_already_exists?
      Trainees::FindDuplicatesOfApplyApplication.call(application_record:).present?
    end

    def mapped_attributes
      {
        apply_application: application_record,
        provider: application_record.provider,
        first_names: raw_trainee["first_name"],
        last_name: raw_trainee["last_name"],
        date_of_birth: raw_trainee["date_of_birth"],
        sex: sex,
        ethnic_group: ethnic_group,
        diversity_disclosure: diversity_disclosure,
        disability_disclosure: disability_disclosure,
        email: raw_contact_details["email"],
        course_uuid: course&.uuid,
        course_education_phase: course&.level,
        course_min_age: course&.min_age,
        course_max_age: course&.max_age,
        training_route: course&.route,
        disabilities: disabilities,
        study_mode: study_mode,
        record_source: Trainee::APPLY_SOURCE,
        application_choice_id: application_record.apply_id,
      }.merge(ethnic_background_attributes)
    end

    def create_degrees!
      ::Degrees::CreateFromApply.call(trainee:)
    end

    def save_personal_details!
      personal_details_form.save!
      verify_nationalities_data!
    end

    def verify_nationalities_data!
      invalid_nationalities = raw_trainee["nationality"] - RecruitsApi::CodeSets::Nationalities::MAPPING.keys

      return if invalid_nationalities.blank?

      Sentry.capture_message("Cannot map nationality from ApplyApplication id: #{application_record.id}, code: #{invalid_nationalities.join(', ')}")
    end

    def sex
      RecruitsApi::CodeSets::Genders::MAPPING[raw_trainee["gender"]] || Trainee.sexes[:sex_not_provided]
    end

    def ethnic_group
      RecruitsApi::CodeSets::Ethnicities::MAPPING.fetch(raw_trainee["ethnic_group"],
                                                        Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    end

    def diversity_disclosure
      return Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] if diversity_disclosed?

      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end

    def disability_disclosure
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] if not_provided?
      return Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] if no_disabilities?

      Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def diversity_disclosed?
      raw_trainee.slice("disabilities", "ethnic_group", "ethnic_background").values.any?(&:present?)
    end

    def not_provided?
      disability_uuids.blank? ||
        disability_uuids.include?(DfEReference::DisabilitiesQuery::PREFER_NOT_TO_SAY_UUID)
    end

    def no_disabilities?
      disability_uuids.include?(DfEReference::DisabilitiesQuery::NO_DISABILITY_UUID)
    end

    def nationality_names
      raw_trainee["nationality"].map { |nationality| RecruitsApi::CodeSets::Nationalities::MAPPING[nationality] }
    end

    def ethnic_background_attributes
      ethnic_background = raw_trainee["ethnic_background"]

      return {} unless ethnic_group && ethnic_group != Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
      return {} unless ethnic_background

      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        { ethnic_background: }
      else
        {
          ethnic_background: Diversities::ANOTHER_BACKGROUND[ethnic_group],
          additional_ethnic_background: ethnic_background,
        }
      end
    end

    def save_other_disability_text!
      trainee.trainee_disabilities.includes(:disability).find_each do |trainee_disability|
        if trainee_disability.disability.uuid == DfEReference::DisabilitiesQuery::OTHER_DISABILITY_UUID
          trainee_disability.update!(additional_disability: other_disability&.dig("text"))
        end
      end
    end

    def other_disability
      raw_trainee["disabilities_and_health_conditions"].find do |disability|
        disability["uuid"] == DfEReference::DisabilitiesQuery::OTHER_DISABILITY_UUID
      end
    end
  end
end

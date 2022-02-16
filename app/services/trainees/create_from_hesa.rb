# frozen_string_literal: true

module Trainees
  class CreateFromHesa
    include ServicePattern
    include DiversityAttributes

    def initialize(student_node:)
      @hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)
      @trainee = Trainee.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
    end

    def call
      trainee.assign_attributes(mapped_attributes)
      trainee.save!
      trainee
      add_multiple_disability_text!
    end

  private

    attr_reader :hesa_trainee, :trainee

    def mapped_attributes
      {
        created_from_hesa: trainee.id.blank?,
        trainee_id: hesa_trainee[:trainee_id],
        training_route: training_route,
      }.merge(personal_details_attributes)
       .merge(contact_attributes)
       .merge(provider_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
    end

    def personal_details_attributes
      {
        first_names: hesa_trainee[:first_names],
        last_name: hesa_trainee[:last_name],
        date_of_birth: hesa_trainee[:date_of_birth],
        gender: hesa_trainee[:gender].to_i,
        nationalities: nationalities,
      }
    end

    def contact_attributes
      {
        email: hesa_trainee[:email],
        address_line_one: hesa_trainee[:address_line_one],
        address_line_two: hesa_trainee[:address_line_two],
      }
    end

    def provider_attributes
      provider = Provider.find_by(ukprn: hesa_trainee[:ukprn])
      provider ? { provider: provider } : {}
    end

    def course_attributes
      {
        course_education_phase: course_education_phase,
        course_subject_one: course_subject_one_name,
        course_subject_two: course_subject_name(hesa_trainee[:course_subject_two]),
        course_subject_three: course_subject_name(hesa_trainee[:course_subject_three]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        study_mode: study_mode,
        itt_start_date: hesa_trainee[:itt_start_date],
        itt_end_date: hesa_trainee[:itt_end_date],
        commencement_date: hesa_trainee[:commencement_date] || hesa_trainee[:itt_start_date],
      }
    end

    def nationalities
      Nationality.where(name: nationality_name)
    end

    def nationality_name
      ApplyApi::CodeSets::Nationalities::MAPPING[hesa_trainee[:nationality]]
    end

    def training_route
      Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_trainee[:training_route]]
    end

    def ethnic_background
      Hesa::CodeSets::Ethnicities::MAPPING[hesa_trainee[:ethnic_background]]
    end

    def disability
      Hesa::CodeSets::Disabilities::MAPPING[hesa_trainee[:disability]]
    end

    def course_subject_name(subject_code)
      Hesa::CodeSets::CourseSubjects::MAPPING[subject_code]
    end

    def course_subject_one_name
      course_subject_name(hesa_trainee[:course_subject_one])
    end

    def course_education_phase
      return if course_subject_one_name.blank?

      return COURSE_EDUCATION_PHASE_ENUMS[:primary] if [
        CourseSubjects::PRIMARY_TEACHING,
        CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS,
      ].include?(course_subject_one_name)

      COURSE_EDUCATION_PHASE_ENUMS[:secondary]
    end

    def study_mode
      Hesa::CodeSets::StudyModes::MAPPING[hesa_trainee[:study_mode]]
    end

    def age_range
      @age_range ||= Hesa::CodeSets::AgeRanges::MAPPING[hesa_trainee[:course_age_range]]
    end
  end
end

# frozen_string_literal: true

module TraineeSerializer
  class V01
    EXCLUDE_ATTRIBUTES = %w[
      id
      slug
    ].freeze

    def initialize(trainee)
      @trainee = trainee
    end

    EXCLUDED_ATTRIBUTES = %w[
      state
    ].freeze

    def as_hash
      @trainee.attributes.except(*EXCLUDE_ATTRIBUTES).merge(
        provider_attribues,
        diversity_attributes,
        course_attributes,
        school_attributes,
        funding_attributes,
        hesa_trainee_attributes,
        nationality: nationality,
        training_initiative: training_initiative,
        placements: placements,
        degrees: degrees,
        state: @trainee.state,
        trainee_id: @trainee.slug,
      )
    end

    def degrees
      @trainee.degrees.map do |degree|
        DegreeSerializer::V01.new(degree).as_hash
      end
    end

    def placements
      @trainee.placements.map do |placement|
        PlacementSerializer::V01.new(placement).as_hash
      end
    end

    def provider_attribues
      {
        ukprn: @trainee.provider&.ukprn,
      }
    end

    def diversity_attributes
      attributes = {
        ethnic_group:,
        ethnic_background:,
        disability_disclosure:,
      }
      assign_disabilities(attributes)

      attributes
    end

    def assign_disabilities(attributes)
      @trainee.hesa_trainee_detail&.hesa_disabilities&.each_with_index do |disability, index|
        key = "disability#{index + 1}"
        attributes[key] = disability
      end
      attributes
    end

    def ethnic_group
      @trainee.ethnic_group
    end

    def ethnic_background
      Hesa::CodeSets::Ethnicities::MAPPING.key(@trainee.ethnic_background)
    end

    def disability_disclosure
      @trainee.disability_disclosure
    end

    def course_attributes
      {
        course_qualification:,
        course_title:,
        course_level:,
        course_itt_subject:,
        course_education_phase:,
        course_study_mode:,
        course_itt_start_date:,
        course_age_range:,
        expected_end_date:,
        trainee_start_date:,
      }
    end

    def course_qualification
      @trainee.award_type
    end

    def course_level
      @trainee.undergrad_route? ? "undergrad" : "postgrad"
    end

    def course_title
      @trainee.published_course&.name
    end

    def course_itt_subject
      @trainee.course_subject_one
    end

    def course_education_phase
      @trainee.course_education_phase
    end

    def course_study_mode
      @trainee.hesa_trainee_detail.course_study_mode
    end

    def course_itt_start_date
      @trainee.itt_start_date&.iso8601
    end

    def course_age_range
      @trainee.hesa_trainee_detail.course_age_range
    end

    def expected_end_date
      @trainee.itt_end_date&.iso8601
    end

    def trainee_start_date
      @trainee.trainee_start_date
    end

    def school_attributes
      {
        employing_school_urn:,
        lead_partner_urn_ukprn:,
        lead_school_urn:,
      }
    end

    def employing_school_urn
      @trainee.employing_school&.urn
    end

    def lead_partner_urn_ukprn
      @trainee.lead_school&.urn
    end

    def lead_school_urn
      @trainee.lead_school&.urn
    end

    def funding_attributes
      {
        fund_code:,
        bursary_level:,
      }
    end

    def fund_code
      @trainee.hesa_trainee_detail.fund_code
    end

    def bursary_level
      @trainee.hesa_trainee_detail.funding_method
    end

    def hesa_trainee_attributes
      HesaTraineeDetailSerializer::V01.new(@trainee.hesa_trainee_detail).as_hash
    end

    def nationality
      @trainee.nationalities.first&.name
    end

    def training_route
      ::Hesa::CodeSets::TrainingRoutes::MAPPING.key(@trainee.training_route)
    end

    def training_initiative
      ::Hesa::CodeSets::TrainingInitiatives::MAPPING.key(@trainee.training_initiative)
    end

    def sex
      ::Hesa::CodeSets::Sexes::MAPPING.key(@trainee.sex)
    end
  end
end

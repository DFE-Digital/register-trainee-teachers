# frozen_string_literal: true

module TraineeSerializer
  class V01
    def initialize(trainee)
      @trainee = trainee
    end

    def as_hash
      @trainee.attributes.merge(
        provider_attribues,
        diversity_attributes,
        course_attributes,
        school_attributes,
        funding_attributes,
        hesa_trainee_attributes,
        nationality: nationality,
        training_initiative: training_initiative,
        placements: @trainee.placements.map(&:attributes),
        degrees: @trainee.degrees.map(&:attributes),
      )
    end

    def provider_attribues
      {
        ukprn: @trainee.provider&.ukprn,
      }
    end

    def diversity_attributes
      {
        ethnicity:,
        ethnicity_background:,
        other_ethnicity_details:,
        disability:,
        other_disability_details:,
      }
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

    def school_attributes
      {
        employing_school_urn:,
        lead_partner_urn_ukprn:,
      }
    end

    def funding_attributes
      {
        fund_code:,
        funding_option:,
      }
    end

    def hesa_trainee_attributes
      HesaTraineeDetailSerializer::V01.new(@trainee.hesa_trainee_detail).as_hash
    end

    def nationality
      @trainee.nationalities.first&.name
    end

    def employing_school_urn
      @trainee.employing_school&.urn
    end

    def lead_partner_urn_ukprn
      @trainee.lead_school&.urn
    end

    def ethnicity; end

    def ethnicity_background; end

    def other_ethnicity_details; end

    def disability; end

    def other_disability_details; end

    def training_route; end

    def course_qualification; end

    def course_level; end

    def course_title
      @trainee.published_course&.name
    end

    def course_itt_subject; end

    def course_education_phase; end

    def course_study_mode; end

    def course_itt_start_date
      @trainee.itt_start_date&.iso8601
    end

    def trainee_start_date
      @trainee.trainee_start_date
    end

    def expected_end_date
      @trainee.itt_end_date&.iso8601
    end

    def course_age_range
      @trainee.course_age_range
    end

    def fund_code; end

    def funding_option; end

    def training_initiative
      # TODO: reverse map from `ROUTE_INITIATIVES_ENUMS` or
      # `::Hesa::CodeSets::TrainingInitiatives::MAPPING`
    end
  end
end

# frozen_string_literal: true

module Api
  module V01
    module HesaMapper
      class Attributes
        include ServicePattern
        include HasDiversityAttributes
        include HasCourseAttributes

        ATTRIBUTES = %i[
          nationality
          ethnic_group
          ethnic_background
          employing_school_urn
          lead_partner_urn
          lead_partner_ukprn
          application_id
        ].freeze

        NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010 900020 900030].freeze
        VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL = "C"
        DISABILITY_PARAM_REGEX = /\Adisability\d+\z/

        def self.disability_attributes(params)
          params[:data].keys.select { |key| key.to_s.match(DISABILITY_PARAM_REGEX) }
        end

        def initialize(params:, update: false)
          @params = params
          @update = update
        end

        def call
          mapped_params
        end

      private

        attr_reader :params, :update

        def mapped_params
          mapped_params = params.except(*ATTRIBUTES).merge({
            sex:,
            training_route:,
            nationalisations_attributes:,
            degrees_attributes:,
            placements_attributes:,
            hesa_disabilities:,
            course_study_mode:,
            application_choice_id:,
          })
          .merge(course_attributes)
          .merge(ethnicity_and_disability_attributes)
          .merge(funding_attributes)
          .merge(training_initiative_attributes)
          .merge(lead_partner_attributes)
          .merge(employing_school_attributes)
          .compact

          if update && !disabilities?
            mapped_params = mapped_params.except(:hesa_disabilities, :disability_disclosure, :disabilities)
          end

          mapped_params
        end

        def ethnicity_attributes
          {
            ethnic_group:,
            ethnic_background:,
          }
        end

        def ethnic_group
          Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first
        end

        def ethnic_background
          return Diversities::NOT_PROVIDED if params.key?(:ethnicity) && params[:ethnicity].blank?

          ::Hesa::CodeSets::Ethnicities::MAPPING[params[:ethnicity]]
        end

        def degrees_attributes
          params[:degrees_attributes]&.map { |degree| HesaMapper::DegreeAttributes.call(degree) }
        end

        def placements_attributes
          params[:placements_attributes]&.map { |placement| HesaMapper::PlacementAttributes.new(placement).call }
        end

        def sex
          ::Hesa::CodeSets::Sexes::MAPPING[params[:sex]] || params[:sex]
        end

        def training_route
          ::Hesa::CodeSets::TrainingRoutes::MAPPING[params[:training_route]]
        end

        def nationalisations_attributes
          return [] unless nationality_name || params[:nationality]

          [{ name: nationality_name || params[:nationality] }]
        end

        def nationality_name
          RecruitsApi::CodeSets::Nationalities::MAPPING[params[:nationality]]
        end

        def disabilities?
          params.to_h.any? { |k, _v| k.to_s.match(DISABILITY_PARAM_REGEX) }
        end

        def hesa_disabilities
          params.select { |k, _v| k.to_s.match(DISABILITY_PARAM_REGEX) }
        end

        def disabilities
          (1..9).map do |n|
            ::Hesa::CodeSets::Disabilities::MAPPING[params[:"disability#{n}"]]
          end.compact
        end

        def itt_start_date
          params[:itt_start_date]
        end

        def itt_end_date
          params[:itt_end_date]
        end

        def itt_qualification_aim
          ::Hesa::CodeSets::IttQualificationAims::MAPPING[params[:itt_qualification_aim]]
        end

        def fundability
          ::Hesa::CodeSets::FundCodes::MAPPING[params[:fund_code]]
        end

        def trainee_start_date
          params[:trainee_start_date].presence || itt_start_date
        end

        def course_subject_name(subject_code)
          ::Hesa::CodeSets::CourseSubjects::MAPPING[subject_code]
        end

        def course_subject_one
          name = course_subject_name(params[:course_subject_one])

          return HesaMapperConstants::INVALID if params[:course_subject_one].present? && name.nil?

          name
        end

        def course_subject_two
          name = course_subject_name(params[:course_subject_two])

          return HesaMapperConstants::INVALID if params[:course_subject_two].present? && name.nil?

          name
        end

        def course_subject_three
          name = course_subject_name(params[:course_subject_three])

          return HesaMapperConstants::INVALID if params[:course_subject_three].present? && name.nil?

          name
        end

        def course_education_phase
          return COURSE_EDUCATION_PHASE_ENUMS[:primary] if primary_education_phase?

          COURSE_EDUCATION_PHASE_ENUMS[:secondary]
        end

        def study_mode
          ::Hesa::CodeSets::StudyModes::MAPPING[params[:study_mode]]
        end

        def course_age_range
          DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[params[:course_age_range]]
        end

        def course_study_mode
          params[:study_mode]
        end

        def course_attributes
          attributes = super

          attributes[:course_allocation_subject_id] = attributes.delete(:course_allocation_subject)&.id

          attributes
        end

        def funding_attributes
          ::Trainees::MapFundingFromDttpEntityId.call(funding_entity_id:)
        end

        def funding_entity_id
          ::Hesa::CodeSets::BursaryLevels::MAPPING[params[:funding_method]]
        end

        def lead_partner_attributes
          if params.key?(:lead_partner_urn)
            lead_partner_from_urn
          elsif params.key?(:lead_partner_ukprn)
            lead_partner_from_ukprn
          else
            { lead_partner_not_applicable: true } unless update
          end
        end

        def lead_partner_from_urn
          lead_partner_id =
            if params[:lead_partner_urn].present?
              LeadPartner.find_by(urn: params[:lead_partner_urn])&.id
            end

          {
            lead_partner_id: lead_partner_id,
            lead_partner_not_applicable: lead_partner_id.nil?,
          }
        end

        def lead_partner_from_ukprn
          lead_partner_id =
            if params[:lead_partner_ukprn].present?
              LeadPartner.find_by(ukprn: params[:lead_partner_ukprn])&.id
            end

          {
            lead_partner_id: lead_partner_id,
            lead_partner_not_applicable: lead_partner_id.nil?,
          }
        end

        def employing_school_attributes
          if params.key?(:employing_school_urn)
            employing_school_id = School.find_by(urn: params[:employing_school_urn])&.id
            {
              employing_school_id: employing_school_id,
              employing_school_not_applicable: employing_school_id.nil?,
            }
          else
            { employing_school_not_applicable: true } unless update
          end
        end

        def training_initiative_attributes
          { training_initiative: training_initiative || ROUTE_INITIATIVES_ENUMS[:no_initiative] }
        end

        def training_initiative
          return ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] if veteran_teaching_undergraduate_bursary?

          ::Hesa::CodeSets::TrainingInitiatives::MAPPING[params[:training_initiative]]
        end

        def veteran_teaching_undergraduate_bursary?
          params[:bursary_level] == VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL
        end

        def application_choice_id
          params[:application_id]
        end
      end
    end
  end
end

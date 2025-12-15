# frozen_string_literal: true

module Api
  module V20260
    module HesaMapper
      class Attributes
        include ServicePattern
        include HasDiversityAttributes
        include HasCourseAttributes

        ATTRIBUTES = %i[
          ethnic_group
          ethnic_background
          employing_school_urn
          lead_partner_urn
          lead_partner_ukprn
          application_id
        ].freeze

        ALLOWED_NIL_PARAMS = %w[
          course_subject_two
          course_subject_three
        ].freeze

        NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010 900020 900030].freeze
        VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL = "C"
        DISABILITY_PARAM_REGEX = /\Adisability\d+\z/

        InvalidValue = Struct.new(:original_value) do
          delegate :to_s, to: :original_value
        end

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
            nationality:,
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
            .merge(training_partner_attributes)
            .merge(employing_school_attributes)
            .compact
            .merge(params_with_allowed_nil_values)

          if update && !disabilities?
            mapped_params = mapped_params.except(:hesa_disabilities, :disability_disclosure, :disabilities)
          end

          mapped_params
        end

        def ethnicity_attributes
          {
            ethnicity:,
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

        def ethnicity
          mapped_value = ::Hesa::CodeSets::Ethnicities::MAPPING[params[:ethnicity]]

          return InvalidValue.new(params[:ethnicity]) if params[:ethnicity].present? && mapped_value.nil?

          mapped_value
        end

        def degrees_attributes
          params[:degrees_attributes]&.map { |degree| Api::V20250::HesaMapper::DegreeAttributes.call(degree) }
        end

        def placements_attributes
          params[:placements_attributes]&.map { |placement| Api::V20250::HesaMapper::PlacementAttributes.new(placement).call }
        end

        def sex
          mapped_value = ::Hesa::CodeSets::Sexes::MAPPING[params[:sex]]

          return InvalidValue.new(params[:sex]) if params[:sex].present? && mapped_value.nil?

          mapped_value || params[:sex]
        end

        def training_route
          mapped_value = ::Hesa::CodeSets::TrainingRoutes::MAPPING[params[:training_route]]

          return InvalidValue.new(params[:training_route]) if params[:training_route].present? && mapped_value.nil?

          mapped_value
        end

        def nationalisations_attributes
          return [] unless nationality_name || params[:nationality]

          [{ name: nationality_name || params[:nationality] }]
        end

        def nationality_name
          RecruitsApi::CodeSets::Nationalities::MAPPING[params[:nationality]]
        end

        def nationality
          mapped_value = RecruitsApi::CodeSets::Nationalities::MAPPING[params[:nationality]]

          return InvalidValue.new(params[:nationality]) if params[:nationality].present? && mapped_value.nil?

          mapped_value
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

        def trainee_start_date
          params[:trainee_start_date]
        end

        def course_subject_name(attr)
          mapped_value = ::Hesa::CodeSets::CourseSubjects::MAPPING[params[attr]]

          return InvalidValue.new(params[attr]) if params[attr].present? && mapped_value.nil?

          mapped_value
        end

        def course_subject_one
          course_subject_name(:course_subject_one)
        end

        def course_subject_two
          course_subject_name(:course_subject_two)
        end

        def course_subject_three
          course_subject_name(:course_subject_three)
        end

        def course_education_phase
          return COURSE_EDUCATION_PHASE_ENUMS[:primary] if primary_education_phase?

          COURSE_EDUCATION_PHASE_ENUMS[:secondary]
        end

        def study_mode
          mapped_value = ::Hesa::CodeSets::StudyModes::MAPPING[params[:study_mode]]

          return InvalidValue.new(params[:study_mode]) if params[:study_mode].present? && mapped_value.nil?

          TRAINEE_STUDY_MODE_ENUMS.invert[mapped_value]
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

        def training_partner_attributes
          if params.key?(:lead_partner_urn)
            training_partner_from_urn
          elsif params.key?(:lead_partner_ukprn)
            training_partner_from_ukprn
          else
            { training_partner_not_applicable: true } unless update
          end
        end

        def training_partner_from_urn
          training_partner_id =
            if params[:lead_partner_urn].present? && !NOT_APPLICABLE_SCHOOL_URNS.include?(params[:lead_partner_urn])
              TrainingPartner.find_by(urn: params[:lead_partner_urn])&.id || InvalidValue.new(params[:lead_partner_urn])
            end

          {
            training_partner_id: training_partner_id,
            training_partner_not_applicable: training_partner_id.nil?,
          }
        end

        def training_partner_from_ukprn
          training_partner_id =
            if params[:lead_partner_ukprn].present?
              TrainingPartner.find_by(ukprn: params[:lead_partner_ukprn])&.id || InvalidValue.new(params[:lead_partner_ukprn])
            end

          {
            training_partner_id: training_partner_id,
            training_partner_not_applicable: training_partner_id.nil?,
          }
        end

        def employing_school_attributes
          if params.key?(:employing_school_urn) && !NOT_APPLICABLE_SCHOOL_URNS.include?(params[:employing_school_urn])
            employing_school_id =
              if params[:employing_school_urn].present?
                School.find_by(urn: params[:employing_school_urn])&.id || InvalidValue.new(params[:employing_school_urn])
              end
            {
              employing_school_id: employing_school_id,
              employing_school_not_applicable: employing_school_id.nil?,
            }
          elsif params.key?(:employing_school_urn) && NOT_APPLICABLE_SCHOOL_URNS.include?(params[:employing_school_urn])
            {
              employing_school_id: nil,
              employing_school_not_applicable: true,
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

          mapped_value = ::Hesa::CodeSets::TrainingInitiatives::MAPPING[params[:training_initiative]]

          return InvalidValue.new(params[:training_initiative]) if params[:training_initiative].present? && mapped_value.nil?

          mapped_value
        end

        def veteran_teaching_undergraduate_bursary?
          params[:bursary_level] == VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL
        end

        def application_choice_id
          params[:application_id]
        end

        def params_with_allowed_nil_values
          # rubocop:disable Rails/IndexWith
          # disabled this cop as it's suggesting a replacement method that does not do what's needed here
          (ALLOWED_NIL_PARAMS & params.select { |_k, v| v.blank? }.keys).to_h { |key| [key, nil] }
          # rubocop:enable Rails/IndexWith
        end
      end
    end
  end
end

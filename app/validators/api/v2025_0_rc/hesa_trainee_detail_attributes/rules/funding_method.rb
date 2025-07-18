# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailAttributes
      module Rules
        class FundingMethod < Api::Rules::Base
          include DateValidatable
          include Api::Rules::AcademicCyclable

          FUNDING_TYPES = {
            Hesa::CodeSets::BursaryLevels::SCHOLARSHIP => FUNDING_TYPES["scholarship"],
            Hesa::CodeSets::BursaryLevels::NONE => nil,
            Hesa::CodeSets::BursaryLevels::TIER_ONE => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::TIER_TWO => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::TIER_THREE => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::UNDERGRADUATE_BURSARY => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::VETERAN_TEACHING_UNDERGRADUATE_BURSARY => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY => FUNDING_TYPES["bursary"],
            Hesa::CodeSets::BursaryLevels::GRANT => FUNDING_TYPES["grant"],
          }.freeze

          attr_reader :hesa_trainee_detail_attributes

          delegate :fund_code,
                   :funding_method,
                   :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_route,
                   :course_subject_one, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return ValidationResult.new(true) if no_funding_method? || funding_method_invalid? || training_route.nil?

            return ValidationResult.new(false, error_details) if fund_code_not_eligible? && funding_method?

            ValidationResult.new(
              funding_method_exists?,
              funding_method_exists? ? nil : error_details,
            )
          end

        private

          def funding_method_exists?
            return false if academic_cycle.nil?

            @funding_method_exists ||= ::FundingMethod.joins(allocation_subjects: :subject_specialisms).exists?(
              academic_cycle_id: academic_cycle.id,
              funding_type: funding_type,
              training_route: training_route.is_a?(Api::V20250Rc::HesaMapper::Attributes::InvalidValue) ? nil : training_route,
              subject_specialisms: { name: course_subject_one.is_a?(Api::V20250Rc::HesaMapper::Attributes::InvalidValue) ? nil : course_subject_one },
            )
          end

          def fund_code_not_eligible?
            !fund_code_eligible?
          end

          def fund_code_eligible?
            fund_code == Hesa::CodeSets::FundCodes::ELIGIBLE
          end

          def funding_method?
            !no_funding_method? && Hesa::CodeSets::BursaryLevels::MAPPING.key?(funding_method.to_s)
          end

          def no_funding_method?
            funding_method.blank? || funding_method == Hesa::CodeSets::BursaryLevels::NONE
          end

          def funding_method_invalid?
            funding_type.blank?
          end

          def funding_type
            @funding_type ||= FUNDING_TYPES[funding_method]
          end

          def error_details
            {
              academic_cycle: academic_cycle&.label,
              subject: course_subject_one,
              funding_type: ::FUNDING_TYPES.invert[funding_type],
              training_route: training_route.to_s,
            }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes
      module Rules
        class FundingMethod < Api::Rules::Base
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
            return true if (fund_code != Hesa::CodeSets::FundCodes::ELIGIBLE && funding_method.blank?) ||
              training_route.nil?

            return false if (fund_code == Hesa::CodeSets::FundCodes::ELIGIBLE && funding_method.blank?) ||
              (fund_code == Hesa::CodeSets::FundCodes::NOT_ELIGIBLE && funding_method.present?)

            ::FundingMethod.joins(allocation_subjects: :subject_specialisms).exists?(
              academic_cycle_id: AcademicCycle.current&.id,
              funding_type: funding_type,
              training_route: training_route,
              subject_specialisms: { name: course_subject_one },
            )
          end

        private

          def funding_type
            @funding_type ||= FUNDING_TYPES.fetch(funding_method)
          end
        end
      end
    end
  end
end

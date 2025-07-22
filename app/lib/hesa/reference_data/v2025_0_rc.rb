# frozen_string_literal: true

# rubocop:disable  Rails/RedundantActiveRecordAllMethod
module Hesa
  module ReferenceData
    class V20250Rc
      include ServicePattern

      def call
        {
          funding_method: CodeSets::BursaryLevels::VALUES,
          institution: DfEReference::DegreesQuery::INSTITUTIONS.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
          grade: DfEReference::DegreesQuery::GRADES.all.pluck(:hesa_code, :name).to_h.reject { |k, _v| k.nil? },
          uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
          non_uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
          disability1: CodeSets::Disabilities::MAPPING,
          disability2: CodeSets::Disabilities::MAPPING,
          disability3: CodeSets::Disabilities::MAPPING,
          disability4: CodeSets::Disabilities::MAPPING,
          disability5: CodeSets::Disabilities::MAPPING,
          disability6: CodeSets::Disabilities::MAPPING,
          disability7: CodeSets::Disabilities::MAPPING,
          disability8: CodeSets::Disabilities::MAPPING,
          disability9: CodeSets::Disabilities::MAPPING,
          country: CodeSets::Countries::MAPPING,
          training_route: CodeSets::TrainingRoutes::MAPPING.transform_values(&:humanize),
          subject: DfEReference::DegreesQuery::SUBJECTS.all.pluck(:hecos_code, :name).to_h.reject { |k, _v| k.nil? },
          ethnicity: CodeSets::Ethnicities::MAPPING,
          fund_code: CodeSets::FundCodes::MAPPING,
          training_initiative: CodeSets::TrainingInitiatives::MAPPING.transform_values(&:humanize),
          itt_aim: CodeSets::IttAims::MAPPING,
          course_age_range: DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.transform_values { |value| "Ages #{value.join('-')}" },
          study_mode: CodeSets::StudyModes::MAPPING.transform_values { |value| Trainee.study_modes.invert[value].humanize },
          itt_qualification_aim: CodeSets::IttQualificationAims::MAPPING,
          sex: CodeSets::Sexes::MAPPING.transform_values { |value| Trainee.sexes.invert[value].humanize },
          course_subject_one: CodeSets::CourseSubjects::MAPPING,
          course_subject_two: CodeSets::CourseSubjects::MAPPING,
          course_subject_three: CodeSets::CourseSubjects::MAPPING,
          nationality: RecruitsApi::CodeSets::Nationalities::MAPPING,
        }.transform_values { |mapping| mapping.sort.to_h }.freeze
      end
    end
  end
end
# rubocop:enable  Rails/RedundantActiveRecordAllMethod

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
          training_route: CodeSets::TrainingRoutes::MAPPING.map { |code, value| [code, value.humanize] }.to_h,
          subject: DfEReference::DegreesQuery::SUBJECTS.all.pluck(:hecos_code, :name).to_h.reject { |k, _v| k.nil? },
          ethnicity: CodeSets::Ethnicities::MAPPING,
          fund_code: CodeSets::FundCodes::MAPPING,
          training_initiative: CodeSets::TrainingInitiatives::MAPPING.map { |code, value| [code, value.humanize] }.to_h,
          itt_aim: CodeSets::IttAims::MAPPING,
          course_age_range: DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.map { |code, value| [code, "Ages #{value.join("-")}"] }.to_h,
          study_mode: CodeSets::StudyModes::MAPPING.map { |code, value| [code, Trainee.study_modes.invert[value].humanize] }.to_h,
          itt_qualification_aim: CodeSets::IttQualificationAims::MAPPING,
          sex: CodeSets::Sexes::MAPPING.map { |code, value| [code, Trainee.sexes.invert[value].humanize] }.to_h,
          course_subject_one: CodeSets::CourseSubjects::MAPPING,
          course_subject_two: CodeSets::CourseSubjects::MAPPING,
          course_subject_three: CodeSets::CourseSubjects::MAPPING,
        }.freeze
      end
    end
  end
end

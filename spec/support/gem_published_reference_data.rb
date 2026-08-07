# frozen_string_literal: true

# Copy of Hesa::ReferenceData::V20250 (removed in ff0e76ac4), kept so specs can check the YAML
# labels still match the gem. Do not update it to match v2026.1.
# rubocop:disable Rails/RedundantActiveRecordAllMethod
module GemPublishedReferenceData
  DEFAULT_CASE_ATTRIBUTES = %i[
    subject
  ].freeze

  LOCALE_NAMESPACES = {
    course_subject_one: "course_subject",
    course_subject_two: "course_subject",
    course_subject_three: "course_subject",
    disability1: "disability",
    disability2: "disability",
    disability3: "disability",
    disability4: "disability",
    disability5: "disability",
    disability6: "disability",
    disability7: "disability",
    disability8: "disability",
    disability9: "disability",
    grade: "degree_grade",
    uk_degree: "degree_type",
    subject: "degree_subject",
  }.freeze

  def self.all
    {
      funding_method: Hesa::CodeSets::BursaryLevels::VALUES,
      institution: DfEReference::DegreesQuery::INSTITUTIONS.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
      grade: DfEReference::DegreesQuery::GRADES.all.pluck(:hesa_code, :name).to_h.reject { |k, _v| k.nil? },
      uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
      non_uk_degree: DfEReference::DegreesQuery::TYPES.all.pluck(:hesa_itt_code, :name).to_h.reject { |k, _v| k.nil? },
      disability1: Hesa::CodeSets::Disabilities::MAPPING,
      disability2: Hesa::CodeSets::Disabilities::MAPPING,
      disability3: Hesa::CodeSets::Disabilities::MAPPING,
      disability4: Hesa::CodeSets::Disabilities::MAPPING,
      disability5: Hesa::CodeSets::Disabilities::MAPPING,
      disability6: Hesa::CodeSets::Disabilities::MAPPING,
      disability7: Hesa::CodeSets::Disabilities::MAPPING,
      disability8: Hesa::CodeSets::Disabilities::MAPPING,
      disability9: Hesa::CodeSets::Disabilities::MAPPING,
      country: Hesa::CodeSets::Countries::MAPPING,
      training_route: Hesa::CodeSets::TrainingRoutes::MAPPING.transform_values(&:humanize),
      subject: DfEReference::DegreesQuery::SUBJECTS.all.pluck(:hecos_code, :name).to_h.reject { |k, _v| k.nil? },
      ethnicity: Hesa::CodeSets::Ethnicities::MAPPING,
      fund_code: Hesa::CodeSets::FundCodes::MAPPING,
      training_initiative: Hesa::CodeSets::TrainingInitiatives::MAPPING.transform_values(&:humanize),
      itt_aim: Hesa::CodeSets::IttAims::MAPPING,
      course_age_range: DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.transform_values { |value| "Ages #{value.join('-')}" },
      study_mode: Hesa::CodeSets::StudyModes::MAPPING.transform_values { |value| Trainee.study_modes.invert[value].humanize },
      itt_qualification_aim: Hesa::CodeSets::IttQualificationAims::MAPPING,
      sex: Hesa::CodeSets::Sexes::MAPPING.transform_values { |value| Trainee.sexes.invert[value].humanize },
      course_subject_one: Hesa::CodeSets::CourseSubjects::MAPPING,
      course_subject_two: Hesa::CodeSets::CourseSubjects::MAPPING,
      course_subject_three: Hesa::CodeSets::CourseSubjects::MAPPING,
      nationality: RecruitsApi::CodeSets::Nationalities::MAPPING,
    }.to_h do |attribute, mapping|
      transformed_mapping = if attribute.in?(DEFAULT_CASE_ATTRIBUTES)
                              mapping.sort
                            else
                              mapping.transform_values { |label| label[0].upcase + label[1..] }.sort
                            end

      locale_namespace    = LOCALE_NAMESPACES.fetch(attribute, attribute)
      translated_mapping  = transformed_mapping.map { |code, label| [code, I18n.t("#{locale_namespace}.#{code}", default: label)] }

      [attribute, translated_mapping.to_h]
    end.freeze
  end
end
# rubocop:enable Rails/RedundantActiveRecordAllMethod

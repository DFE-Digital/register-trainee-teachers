# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Load Nationalities
Nationality.upsert_all(
  CodeSets::Nationalities::MAPPING.keys.map do |nationality|
    { name: nationality }.merge(created_at: Time.zone.now, updated_at: Time.zone.now)
  end,
  unique_by: :name,
)

# Load Disabilities
Disability.upsert_all(
  Diversities::SEED_DISABILITIES.map do |disability|
    disability.merge(created_at: Time.zone.now, updated_at: Time.zone.now)
  end,
  unique_by: :name,
)

# Load Withdrawal reasons
WithdrawalReason.upsert_all(WithdrawalReasons::SEED, unique_by: :name)

allocation_subjects = AllocationSubject.upsert_all(
  AllocationSubjects.constants.map do |allocation_subject|
    {
      name: AllocationSubjects.const_get(allocation_subject),
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
    }
  end,
  unique_by: :name,
  returning: %i[name id],
)

SubjectSpecialism.upsert_all(
  allocation_subjects.rows.flat_map do |allocation_subject_name, allocation_subject_id|
    ALLOCATION_SUBJECT_SPECIALISM_MAPPING[allocation_subject_name].map do |subject_specialism_name|
      next if allocation_subject_name == AllocationSubjects::MODERN_LANGUAGES && subject_specialism_name.in?([CourseSubjects::FRENCH_LANGUAGE, CourseSubjects::GERMAN_LANGUAGE, CourseSubjects::SPANISH_LANGUAGE])

      {
        name: subject_specialism_name,
        hecos_code: DegreeSubjects::MAPPING.dig(CourseSubjects::MAPPING[subject_specialism_name], :hecos_code),
        allocation_subject_id: allocation_subject_id,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      }
    end
  end.compact,
  unique_by: :name,
)

ACADEMIC_CYCLES.each do |academic_cycle|
  AcademicCycle.find_or_create_by!(start_date: academic_cycle[:start_date], end_date: academic_cycle[:end_date])
end

[
  {
    academic_cycle: AcademicCycle.for_year(2020),
    bursaries: BURSARIES_2020_TO_2021,
    scholarships: SCHOLARSHIPS_2020_TO_2021,
    grants: GRANTS_2020_TO_2021,
  },
  {
    academic_cycle: AcademicCycle.for_year(2021),
    bursaries: BURSARIES_2021_TO_2022,
    scholarships: SCHOLARSHIPS_2021_TO_2022,
    grants: GRANTS_2021_TO_2022,
  },
  {
    academic_cycle: AcademicCycle.for_year(2022),
    bursaries: BURSARIES_2022_TO_2023,
    scholarships: SCHOLARSHIPS_2022_TO_2023,
    grants: GRANTS_2022_TO_2023,
  },
  {
    academic_cycle: AcademicCycle.for_year(2023),
    bursaries: BURSARIES_2023_TO_2024,
    scholarships: SCHOLARSHIPS_2023_TO_2024,
    grants: GRANTS_2023_TO_2024,
  },
  {
    academic_cycle: AcademicCycle.for_year(2024),
    bursaries: BURSARIES_2024_TO_2025,
    scholarships: SCHOLARSHIPS_2024_TO_2025,
    grants: GRANTS_2024_TO_2025,
  },
  {
    academic_cycle: AcademicCycle.for_year(2025),
    bursaries: BURSARIES_2025_TO_2026,
    scholarships: SCHOLARSHIPS_2025_TO_2026,
    grants: GRANTS_2025_TO_2026,
  },
  {
    academic_cycle: AcademicCycle.for_year(2026),
    bursaries: BURSARIES_2026_TO_2027,
    scholarships: SCHOLARSHIPS_2026_TO_2027,
    grants: GRANTS_2026_TO_2027,
  },
].each do |rule|
  rule[:bursaries].each do |b|
    bursary = FundingMethod.find_or_create_by!(training_route: b.training_route,
                                               amount: b.amount,
                                               funding_type: FUNDING_TYPE_ENUMS[:bursary],
                                               academic_cycle: rule[:academic_cycle])
    b.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      bursary.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end
  end

  rule[:scholarships].each do |s|
    funding_method = FundingMethod.find_or_create_by!(training_route: s.training_route,
                                                      amount: s.amount,
                                                      funding_type: FUNDING_TYPE_ENUMS[:scholarship],
                                                      academic_cycle: rule[:academic_cycle])
    s.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end
  end

  rule[:grants].each do |s|
    funding_method = FundingMethod.find_or_create_by!(training_route: s.training_route,
                                                      amount: s.amount,
                                                      funding_type: FUNDING_TYPE_ENUMS[:grant],
                                                      academic_cycle: rule[:academic_cycle])
    s.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)j
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject:)
    end
  end
end

NewGroup.reset_column_information
NewGroup.create!(description: "First group", email: "first@group.com")
NewGroup.create!(description: "Second group", email: "second@group.com")
NewGroup.create!(description: "Third group", email: "third@group.com")

NewSchool.create!(description: "School 1")

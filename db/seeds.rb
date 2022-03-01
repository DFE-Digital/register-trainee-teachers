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
  Dttp::CodeSets::Nationalities::MAPPING.keys.map do |nationality|
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

allocation_subjects = AllocationSubject.upsert_all(
  ALLOCATION_SUBJECT_SPECIALISM_MAPPING.keys.map do |allocation_subject|
    {
      name: allocation_subject,
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
    }
  end,
  unique_by: :name,
  returning: %w[name id],
)

SubjectSpecialism.upsert_all(
  allocation_subjects.rows.flat_map do |allocation_subject_name, allocation_subject_id|
    ALLOCATION_SUBJECT_SPECIALISM_MAPPING[allocation_subject_name].map do |subject_specialism_name|
      {
        name: subject_specialism_name,
        allocation_subject_id: allocation_subject_id,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      }
    end
  end,
  unique_by: :index_subject_specialisms_on_lower_name,
)

ACADEMIC_CYCLES.each do |academic_cycle|
  AcademicCycle.find_or_create_by!(start_date: academic_cycle[:start_date], end_date: academic_cycle[:end_date])
end

(Settings.current_default_course_year..Time.zone.today.year).each do |year|
  academic_cycle = AcademicCycle.for_year(year)

  SEED_BURSARIES.each do |b|
    bursary = FundingMethod.find_or_create_by!(training_route: b.training_route,
                                               amount: b.amount,
                                               academic_cycle: academic_cycle)
    bursary.funding_type = :bursary
    bursary.save!

    b.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      bursary.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
    end
  end

  SEED_SCHOLARSHIPS.each do |s|
    funding_method = FundingMethod.find_or_create_by!(training_route: s.training_route,
                                                      amount: s.amount,
                                                      funding_type: FUNDING_TYPE_ENUMS[:scholarship],
                                                      academic_cycle: academic_cycle)
    s.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
    end
  end

  SEED_GRANTS.each do |s|
    funding_method = FundingMethod.find_or_create_by!(training_route: s.training_route,
                                                      amount: s.amount,
                                                      funding_type: FUNDING_TYPE_ENUMS[:grant],
                                                      academic_cycle: academic_cycle)
    s.allocation_subjects.map do |subject|
      allocation_subject = AllocationSubject.find_by!(name: subject)
      funding_method.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
    end
  end
end

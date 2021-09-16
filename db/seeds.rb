# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Load Nationalities
Dttp::CodeSets::Nationalities::MAPPING.each_key do |nationality|
  Nationality.find_or_create_by(name: nationality)
end

# Load Disabilities
Diversities::SEED_DISABILITIES.each do |disability|
  Disability.find_or_create_by!(name: disability.name).update(description: disability.description)
end

ALLOCATION_SUBJECT_SPECIALISM_MAPPING.each do |allocation_subject, subject_specialisms|
  allocation_subject = AllocationSubject.find_or_create_by!(name: allocation_subject)
  if allocation_subject.name == AllocationSubjects::PRIMARY
    allocation_subject.subject_specialisms.find_or_create_by!(name: CourseSubjects::PRIMARY_TEACHING)
  else
    subject_specialisms.each do |subject_specialism_name|
      allocation_subject.subject_specialisms.find_or_create_by!(name: subject_specialism_name)
    end
  end
end

SEED_BURSARIES.each do |b|
  bursary = FundingMethod.find_or_create_by!(training_route: b.training_route, amount: b.amount)
  bursary.funding_type = :bursary
  bursary.save!
  b.allocation_subjects.map do |subject|
    allocation_subject = AllocationSubject.find_by!(name: subject)
    bursary.funding_method_subjects.find_or_create_by!(allocation_subject: allocation_subject)
  end
end

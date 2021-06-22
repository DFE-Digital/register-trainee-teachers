# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Load Nationalities
Dttp::CodeSets::Nationalities::MAPPING.keys.each do |nationality|
  Nationality.find_or_create_by(name: nationality)
end

# Load Disabilities
Diversities::SEED_DISABILITIES.each do |disability|
  Disability.find_or_create_by!(name: disability.name, description: disability.description)
end

Dttp::CodeSets::AllocationSubjects::MAPPING.each do |allocation_subject, metadata|
  allocation_subject = AllocationSubject.find_or_create_by!(name: allocation_subject)
  metadata[:subject_specialisms].each do |subject_specialism|
    allocation_subject.subject_specialisms.find_or_create_by!(name: subject_specialism[:name])
  end
end

SEED_BURSARIES.each do |b|
  bursary = Bursary.find_or_create_by!(training_route: b.training_route, amount: b.amount)
  b.allocation_subjects.map do |subject|
    allocation_subject = AllocationSubject.find_by!(name: subject)
    bursary.bursary_subjects.create!(allocation_subject: allocation_subject)
  end
end

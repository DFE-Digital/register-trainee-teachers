# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Load Nationalities
Nationalities::SEED_NATIONALITIES.each do |nationality|
  Nationality.find_or_create_by(name: nationality)
end

# Load Disabilities
Diversities::SEED_DISABILITIES.each do |disability|
  Disability.find_or_create_by!(name: disability.name, description: disability.description)
end

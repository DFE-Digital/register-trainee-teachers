# frozen_string_literal: true

module SeedHelper
  def generate_seed_diversities
    Disability.upsert_all(disability_attributes, unique_by: :name)
  end

  def generate_seed_nationalities
    Nationality.upsert_all(nationality_attributes, unique_by: :name)
  end

private

  def disability_attributes
    Diversities::SEED_DISABILITIES.map do |disability|
      disability.merge(created_at: Time.zone.now, updated_at: Time.zone.now)
    end
  end

  def nationality_attributes
    Dttp::CodeSets::Nationalities::MAPPING.keys.map do |nationality|
      { name: nationality }.merge(created_at: Time.zone.now, updated_at: Time.zone.now)
    end
  end
end

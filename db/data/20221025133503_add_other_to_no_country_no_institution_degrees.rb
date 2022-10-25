# frozen_string_literal: true

class AddOtherToNoCountryNoInstitutionDegrees < ActiveRecord::Migration[6.1]
  def up
    degrees.update_all(
      locale_code: :uk,
      institution: institution,
      institution_uuid: institution_uuid,
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def institution
    ::Dttp::CodeSets::Institutions::OTHER_UK
  end

  def institution_uuid
    ::Dttp::CodeSets::Institutions::MAPPING[institution][:entity_id]
  end

  def degrees
    @degrees ||= Degree
      .includes(:trainee)
      .where.not(trainee: { hesa_id: nil })
      .where(
        locale_code: "non_uk",
        country: nil,
        institution: nil,
        created_at: Date.new(2022, 10, 01)..Time.zone.today.end_of_day,
      )
  end
end

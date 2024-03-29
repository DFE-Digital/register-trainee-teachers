# frozen_string_literal: true

class AddOtherToNoCountryNoInstitutionDegrees < ActiveRecord::Migration[6.1]
  def up
    degrees.update_all(
      locale_code: :uk,
      institution: institution.name,
      institution_uuid: institution.id,
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def institution
    DfEReference::DegreesQuery.find_institution(name: "Other UK institution")
  end

  def degrees
    @degrees ||= Degree
      .includes(:trainee)
      .where.not(trainee: { hesa_id: nil })
      .where(
        locale_code: "non_uk",
        country: nil,
        institution: nil,
        created_at: Date.new(2022, 10, 1)..Time.zone.today.end_of_day,
      )
  end
end

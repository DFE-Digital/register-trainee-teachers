# frozen_string_literal: true

class BackfillTraineePlacements < ActiveRecord::Migration[7.0]
  def up
    Trainee.joins(:hesa_students).find_each do |trainee|
      hesa_student = trainee.hesa_students.latest
      hesa_urns = hesa_student&.placements&.map { |placement| placement["school_urn"] }
      schools = School.where(urn: hesa_urns)

      if schools.present?
        # If we have real schools, link them
        schools.find_each do |school|
          trainee.placements.find_or_create_by(school:)
        end
      else
        # Else we must be getting a not applicable urn. See the list here: Trainee::NOT_APPLICABLE_SCHOOL_URNS
        hesa_urns.each do |urn|
          # Skip if the urn is not among Trainee::NOT_APPLICABLE_SCHOOL_URNS
          next if Trainee::NOT_APPLICABLE_SCHOOL_URNS.exclude?(urn)

          trainee.placements.find_or_create_by(
            {
              urn: urn,
              name: I18n.t("components.placement_detail.magic_urn.#{urn}"),
            },
          )
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

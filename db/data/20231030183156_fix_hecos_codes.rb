# frozen_string_literal: true

class FixHecosCodes < ActiveRecord::Migration[7.0]
  def up
    [
      ["general sciences", "general science", "100390"],
      ["ancient Hebrew", "ancient Hebrew language", "101117"],
      ["classical Greek studies", nil, "101126"],
      ["Latin language", nil, "101420"],
    ].each do |name, new_name, hecos_code|
      sp = SubjectSpecialism.find_by(name:)
      next unless sp

      name = new_name if new_name

      sp.update(name:, hecos_code:)
    end

    SubjectSpecialism.find_or_create_by(
      name: "teaching English as a foreign language",
      hecos_code: "100513",
      allocation_subject_id: AllocationSubject.find_by(name: "English").id,
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

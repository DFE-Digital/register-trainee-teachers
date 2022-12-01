# frozen_string_literal: true

class BackfillMissingInstitutionUuids < ActiveRecord::Migration[6.1]
  def up
    institutions = {
      "The Queen's University of Belfast" => "a7db7129-7042-e811-80ff-3863bb3640b8",
      "The University of Wales (central functions)" => "6a228041-7042-e811-80ff-3863bb3640b8",
      "Ravensbourne" => "4ff3791d-7042-e811-80ff-3863bb3640b8",
      "St George's Hospital Medical School" => "94407223-7042-e811-80ff-3863bb3640b8",
      "Leeds College of Music" => "733e182c-1425-ec11-b6e6-000d3adf095a",
    }

    institutions.each do |institution, uuid|
      Degree.where(institution:).update_all(institution_uuid: uuid)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class AddDeprecatedAllocationSubjects < ActiveRecord::Migration[6.1]
  def up
    {
      "Psychology" => "f5f10516-aac2-e611-80be-00155d010316",
      "Primary Mathematics Specialist" => "f1f10516-aac2-e611-80be-00155d010316",
      "Social Sciences" => "f9f10516-aac2-e611-80be-00155d010316",
      "Primary - General (Mathematics)" => "fdf10516-aac2-e611-80be-00155d010316",
      "Travel And Tourism" => "d3f10516-aac2-e611-80be-00155d010316",
      "Physics with maths" => "e7f10516-aac2-e611-80be-00155d010316",
      "Citizenship" => "b7f10516-aac2-e611-80be-00155d010316",
    }.each do |name, dttp_id|
      AllocationSubject.create(name: name, dttp_id: dttp_id, deprecated_on: Time.zone.today)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

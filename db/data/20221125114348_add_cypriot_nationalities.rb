# frozen_string_literal: true

class AddCypriotNationalities < ActiveRecord::Migration[6.1]
  CYPRIOT_NATIONALITIES = [
    { name: "cypriot (european union)" },
    { name: "cypriot (non european union)" },
  ].freeze

  def up
    CYPRIOT_NATIONALITIES.each do |n|
      Nationality.find_or_create_by!(name: n[:name])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

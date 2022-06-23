# frozen_string_literal: true

class AddInstitutionUuidColumnToDegrees < ActiveRecord::Migration[6.1]
  def change
    add_column :degrees, :institution_uuid, :uuid
  end
end

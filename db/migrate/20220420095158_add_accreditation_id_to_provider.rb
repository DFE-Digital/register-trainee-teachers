# frozen_string_literal: true

class AddAccreditationIdToProvider < ActiveRecord::Migration[6.1]
  def change
    add_column :providers, :accreditation_id, :string
    add_index :providers, :accreditation_id
  end
end

# frozen_string_literal: true

class CreateNewGroups < ActiveRecord::Migration[7.2]
  class NewGroup < ActiveRecord::Base
    self.table_name = "new_groups"
  end

  def change
    create_table :new_groups do |t|
      t.string :description
      t.string :email

      t.timestamps
    end

    safety_assured do
      NewGroup.reset_column_information
      NewGroup.create!(description: "First group", email: "first@group.com")
      NewGroup.create!(description: "Second group", email: "second@group.com")
      NewGroup.create!(description: "Third group", email: "third@group.com")
    end
  end
end

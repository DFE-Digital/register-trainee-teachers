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
    end
  end
end

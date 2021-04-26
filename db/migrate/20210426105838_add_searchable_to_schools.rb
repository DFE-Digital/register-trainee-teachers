# frozen_string_literal: true

class AddSearchableToSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :schools, :searchable, :tsvector
    add_index :schools, :searchable, using: :gin
    add_index :schools, :close_date, where: "close_date is NULL"
  end

  def down
    remove_index :schools, :searchable
    remove_index :schools, :close_date
    remove_column :schools, :searchable
  end
end

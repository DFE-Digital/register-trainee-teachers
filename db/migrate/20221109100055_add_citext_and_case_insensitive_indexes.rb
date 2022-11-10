# frozen_string_literal: true

class AddCitextAndCaseInsensitiveIndexes < ActiveRecord::Migration[6.1]
  def up
    enable_extension("citext")

    remove_index :trainees, :slug, unique: true
    change_column :trainees, :slug, :citext
    add_index :trainees, :slug, unique: true

    remove_index :degrees, :slug, unique: true
    change_column :degrees, :slug, :citext
    add_index :degrees, :slug, unique: true
  end

  def down
    remove_index :trainees, :slug, unique: true
    change_column :trainees, :slug, :string
    add_index :trainees, :slug, unique: true

    remove_index :degrees, :slug, unique: true
    change_column :degrees, :slug, :string
    add_index :degrees, :slug, unique: true

    disable_extension("citext")
  end
end

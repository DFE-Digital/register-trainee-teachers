# frozen_string_literal: true

class AddSearchableToProviders < ActiveRecord::Migration[7.1]
  def up
    safety_assured {
      add_column :providers, :searchable, :tsvector
      add_index :providers, :searchable, using: :gin
    }
  end

  def down
    safety_assured {
      remove_index :providers, :searchable
      remove_column :providers, :searchable
    }
  end
end

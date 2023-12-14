# frozen_string_literal: true

class UpdateProivderSearchable < ActiveRecord::Migration[7.1]
  def up
    # triggers the #update_searchable for each provider record
    Provider.find_each(&:save)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

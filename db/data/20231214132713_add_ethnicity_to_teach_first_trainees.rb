# frozen_string_literal: true

class AddEthnicityToTeachFirstTrainees < ActiveRecord::Migration[7.1]
  def up
    DataMigrations::AddEthnicityToTeachFirstTrainees.new.call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

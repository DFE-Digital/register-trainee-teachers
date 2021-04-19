# frozen_string_literal: true

class ChangeDttpProvidersDttpIdToUuid < ActiveRecord::Migration[6.1]
  def up
    change_column :dttp_providers, :dttp_id, "uuid USING dttp_id::uuid"
  end

  def down
    change_column :dttp_providers, :dttp_id, :string
  end
end

# frozen_string_literal: true

class RemoveNullConstraintFromDttpTrainees < ActiveRecord::Migration[6.1]
  def change
    change_column_null :dttp_trainees, :provider_dttp_id, true
  end
end

# frozen_string_literal: true

class ChangeSlugNullabilityOnTrainees < ActiveRecord::Migration[6.1]
  def change
    change_column_null :trainees, :slug, false
  end
end

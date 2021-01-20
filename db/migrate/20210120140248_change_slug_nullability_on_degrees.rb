# frozen_string_literal: true

class ChangeSlugNullabilityOnDegrees < ActiveRecord::Migration[6.1]
  def change
    change_column_null :degrees, :slug, false
  end
end

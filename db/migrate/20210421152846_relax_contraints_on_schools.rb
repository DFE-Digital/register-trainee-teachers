# frozen_string_literal: true

class RelaxContraintsOnSchools < ActiveRecord::Migration[6.1]
  def change
    change_column_null :schools, :postcode, true
    change_column_null :schools, :town, true
  end
end

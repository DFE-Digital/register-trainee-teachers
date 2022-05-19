# frozen_string_literal: true

class ChangeHesaIdTypeToStringInHesaStudents < ActiveRecord::Migration[6.1]
  def up
    change_column :hesa_students, :hesa_id, :string
  end
end

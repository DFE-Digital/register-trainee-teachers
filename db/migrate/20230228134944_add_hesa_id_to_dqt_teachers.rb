# frozen_string_literal: true

class AddHesaIdToDqtTeachers < ActiveRecord::Migration[7.0]
  def change
    add_column :dqt_teachers, :hesa_id, :string
  end
end

# frozen_string_literal: true

class AddCollectionReferenceToHesaStudents < ActiveRecord::Migration[6.1]
  def change
    add_column :hesa_students, :collection_reference, :string
  end
end

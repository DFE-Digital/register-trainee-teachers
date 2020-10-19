class AddColumnsToDegrees < ActiveRecord::Migration[6.0]
  def change
    change_table :degrees, bulk: true do |t|
      t.column :degree_subject, :string, null: true
      t.column :institution, :string, null: true
      t.column :graduation_year, :integer, null: true
      t.column :degree_grade, :string, null: true
    end
  end
end

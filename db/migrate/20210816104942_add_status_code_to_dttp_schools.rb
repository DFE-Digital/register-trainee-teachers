class AddStatusCodeToDttpSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :dttp_schools, :status_code, :integer
  end
end

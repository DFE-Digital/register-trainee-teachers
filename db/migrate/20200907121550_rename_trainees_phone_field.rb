class RenameTraineesPhoneField < ActiveRecord::Migration[6.0]
  def change
    rename_column :trainees, :phone, :phone_number
  end
end

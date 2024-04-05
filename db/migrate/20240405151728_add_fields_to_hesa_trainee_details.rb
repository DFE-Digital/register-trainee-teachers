class AddFieldsToHesaTraineeDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :hesa_trainee_details, :itt_qualification_aim, :string
    add_column :hesa_trainee_details, :fund_code, :string
  end
end

class RemoveFundCodeFromHesaTraineeDetails < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :hesa_trainee_details, :fund_code, :string }
  end
end

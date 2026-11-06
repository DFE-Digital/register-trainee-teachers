class AddErrorMessageToFundingUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :funding_uploads, :error_message, :string
  end
end

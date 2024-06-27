class AddLeadPartnerIdToTrainees < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :trainees, :lead_partner, index: {algorithm: :concurrently}
  end
end

# frozen_string_literal: true

class RenameDoctorOfPhilosphy < ActiveRecord::Migration[6.1]
  def up
    dphil_id = "656a5652-c197-e711-80d8-005056ac45bb"
    Degree.where(uk_degree_uuid: dphil_id).update_all(uk_degree: "Doctor of Philosophy (DPhil)")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

# frozen_string_literal: true

class MigrateLeadSchoolRecordTypeToSchool < ActiveRecord::Migration[7.2]
  def up
    LeadPartner.where(record_type: "lead_school").update_all(record_type: "school")
  end

  def down
    LeadPartner.where(record_type: "school").update_all(record_type: "lead_school")
  end
end

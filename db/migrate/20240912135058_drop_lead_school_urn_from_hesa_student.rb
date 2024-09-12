# frozen_string_literal: true

class DropLeadSchoolUrnFromHesaStudent < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :hesa_students, :lead_school_urn, :string }
  end
end

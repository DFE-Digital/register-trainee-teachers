# frozen_string_literal: true

class AlterLeadPartnersUrnRemoveNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :lead_partners, :urn, true
  end
end

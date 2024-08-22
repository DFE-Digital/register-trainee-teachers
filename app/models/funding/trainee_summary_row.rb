# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_trainee_summary_rows
#
#  id                         :bigint           not null, primary key
#  cohort_level               :string
#  lead_partner_urn           :string
#  lead_school_name           :string
#  lead_school_urn            :string
#  route                      :string
#  route_type                 :string
#  subject                    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  funding_trainee_summary_id :integer
#
# Indexes
#
#  index_trainee_summary_rows_on_trainee_summary_id  (funding_trainee_summary_id)
#
module Funding
  class TraineeSummaryRow < ApplicationRecord
    include LeadSchoolMigratable

    set_lead_columns :lead_school_urn, :lead_partner_urn

    self.table_name = "funding_trainee_summary_rows"

    belongs_to :trainee_summary,
               class_name: "Funding::TraineeSummary",
               foreign_key: :funding_trainee_summary_id,
               inverse_of: :rows

    has_many :amounts,
             class_name: "Funding::TraineeSummaryRowAmount",
             foreign_key: :funding_trainee_summary_row_id,
             dependent: :destroy,
             inverse_of: :row

    enum :route_type, {
      school_direct_salaried: "school_direct_salaried",
      pg_teaching_apprenticeship: "pg_teaching_apprenticeship",
      early_years_postgrad: "early_years_postgrad",
      early_years_salaried: "early_years_salaried",
      provider_led: "provider_led",
      opt_in_undergrad: "opt_in_undergrad",
      school_direct_tuition_fee: "school_direct_tuition_fee",
    }

    def route
      return super if route_type.nil?

      self.class.human_attribute_name(route_type)
    end
  end
end

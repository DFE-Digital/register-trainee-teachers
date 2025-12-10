# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_trainee_summary_rows
#
#  id                         :bigint           not null, primary key
#  cohort_level               :string
#  lead_partner_name          :string
#  lead_partner_urn           :string
#  lead_school_name           :string
#  lead_school_urn            :string
#  route                      :string
#  subject                    :string
#  training_route             :string
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

    set_lead_columns :lead_school_urn, :training_partner_urn

    self.table_name = "funding_trainee_summary_rows"

    before_save :sync_lead_school_and_partner_name

    belongs_to :trainee_summary,
               class_name: "Funding::TraineeSummary",
               foreign_key: :funding_trainee_summary_id,
               inverse_of: :rows

    has_many :amounts,
             class_name: "Funding::TraineeSummaryRowAmount",
             foreign_key: :funding_trainee_summary_row_id,
             dependent: :destroy,
             inverse_of: :row

    enum :training_route, {
      school_direct_salaried: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
      pg_teaching_apprenticeship: TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
      early_years_postgrad: TRAINING_ROUTE_ENUMS[:early_years_postgrad],
      early_years_salaried: TRAINING_ROUTE_ENUMS[:early_years_salaried],
      provider_led_postgrad: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
      provider_led_undergrad: TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
      opt_in_undergrad: TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
      school_direct_tuition_fee: TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
      teacher_degree_apprenticeship: TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship],
    }

    def route
      return super if training_route.nil?

      self.class.human_attribute_name(training_route)
    end

    def sync_lead_school_and_partner_name
      school_name_changed = changed.include?("lead_school_name")
      partner_name_changed = changed.include?("training_partner_name")

      if school_name_changed
        self.training_partner_name = lead_school_name
      elsif partner_name_changed
        self.lead_school_name = training_partner_name
      end
    end
  end
end

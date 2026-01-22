# frozen_string_literal: true

module LeadSchoolMigratable
  extend ActiveSupport::Concern

  included do
    class << self
      attr_accessor :training_partner_column, :lead_school_column

      def set_lead_columns(school, partner)
        @lead_school_column = school
        @training_partner_column = partner
      end
    end

    before_save :sync_lead_partner_and_school
  end

  def sync_lead_partner_and_school
    partner_col = self.class.training_partner_column
    school_col = self.class.lead_school_column
    partner_changed = changed.include?(partner_col.to_s)
    school_changed = changed.include?(school_col.to_s)

    if (partner_changed && school_changed) || school_changed
      send("#{partner_col}=", send(school_col))
    elsif partner_changed
      send("#{school_col}=", send(partner_col))
    end
  end
end

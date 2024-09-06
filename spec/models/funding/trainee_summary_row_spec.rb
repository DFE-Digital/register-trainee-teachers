# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRow do
    describe "associations" do
      it { is_expected.to belong_to(:trainee_summary) }
      it { is_expected.to have_many(:amounts) }
    end

    describe "Lead School Migration" do
      let(:user) { create(:user) }
      let(:summary) { create(:trainee_summary, payable: user.providers.first) }
      let(:row) { create(:trainee_summary_row, trainee_summary: summary) }

      it "includes the LeadSchoolMigratable concern" do
        expect(Funding::TraineeSummaryRow.included_modules).to include(LeadSchoolMigratable)
      end

      it "calls set_lead_columns with the correct arguments" do
        expect(Funding::TraineeSummaryRow).to receive(:set_lead_columns).with(:lead_school_urn, :lead_partner_urn)
        load Rails.root.join("app/models/funding/trainee_summary_row.rb")
      end

      it "syncs the lead school name and lead partner name" do
        row.update(lead_school_name: "School")
        expect(row.lead_partner_name).to eq("School")
        row.update(lead_partner_name: "Partner")
        expect(row.lead_school_name).to eq("Partner")
      end
    end
  end
end

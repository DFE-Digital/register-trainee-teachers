# frozen_string_literal: true

require "rails_helper"

describe LeadSchoolMigratable do
  let(:row) { create(:bulk_update_recommendations_upload_row) }

  context "when lead_partner is changed" do
    before do
      row.lead_partner = "Lead Partner"
      row.save
    end

    it "sets lead_school to the value of lead_partner" do
      expect(row.lead_school).to eq("Lead Partner")
    end
  end

  context "when lead_school is changed" do
    before do
      row.lead_school = "Lead School"
      row.save
    end

    it "sets lead_partner to the value of lead_school" do
      expect(row.lead_partner).to eq("Lead School")
    end
  end

  context "when both lead_partner and lead_school are changed" do
    before do
      row.lead_partner = "Lead Partner"
      row.lead_school = "Lead School"
      row.save
    end

    it "sets lead_partner to the value of lead_school" do
      expect(row.lead_partner).to eq("Lead School")
    end

    it "keeps lead_school as originally set" do
      expect(row.lead_school).to eq("Lead School")
    end
  end

  context "when neither lead_partner nor lead_school are changed" do
    before { row.update(trn: "12345") }

    it "does not change lead_partner" do
      expect(row.lead_partner).to be_nil
    end

    it "does not change lead_school" do
      expect(row.lead_school).to be_nil
    end
  end
end
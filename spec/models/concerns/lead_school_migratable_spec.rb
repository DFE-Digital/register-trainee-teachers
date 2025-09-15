# frozen_string_literal: true

require "rails_helper"

describe LeadSchoolMigratable do
  let(:user) { create(:user) }
  let(:trainee_summary) { create(:trainee_summary, payable: user.providers.first) }
  let(:row) { create(:trainee_summary_row, trainee_summary:) }

  context "when lead_partner_urn is changed" do
    before do
      row.lead_partner_urn = "Training Partner"
      row.save
    end

    it "sets lead_school to the value of lead_partner" do
      expect(row.lead_school_urn).to eq("Training Partner")
    end
  end

  context "when lead_school is changed" do
    before do
      row.lead_school_urn = "Lead School"
      row.save
    end

    it "sets lead_partner to the value of lead_school" do
      expect(row.lead_partner_urn).to eq("Lead School")
    end
  end

  context "when both lead_partner and lead_school are changed" do
    before do
      row.lead_partner_urn = "Training Partner"
      row.lead_school_urn = "Lead School"
      row.save
    end

    it "sets lead_partner_urn to the value of lead_school_urn" do
      expect(row.lead_partner_urn).to eq("Lead School")
    end

    it "keeps lead_school_urn as originally set" do
      expect(row.lead_school_urn).to eq("Lead School")
    end
  end

  context "when neither lead_partner nor lead_school are changed" do
    it "does not change lead_partner" do
      expect { row.update(route: "12345") }.not_to change { row.lead_partner_urn }
    end

    it "does not change lead_school" do
      expect { row.update(route: "12345") }.not_to change { row.lead_school_urn }
    end
  end
end

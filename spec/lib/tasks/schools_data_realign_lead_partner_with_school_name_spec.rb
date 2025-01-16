# frozen_string_literal: true

require "rails_helper"

describe "schools_data:realign_lead_partner_with_school_name" do
  let(:school1) { create(:school, name: "Test School 1") }
  let(:school2) { create(:school, name: "Test School 2") }
  let(:school3) { create(:school, name: "Test School 3") }

  let(:lead_partner1) { create(:lead_partner, :school, name: "Test Lead Partner 1", school: school1) }
  let(:lead_partner2) { create(:lead_partner, :school, name: "Test Lead Partner 2", school: school2) }
  let(:lead_partner3) { create(:lead_partner, :school, name: "Test School 3", school: school3) }

  before do
    allow($stdout).to receive(:puts)
    lead_partner1.update(name: "Different Name 1")
    lead_partner2
    lead_partner3
  end

  subject do
    Rake::Task["schools_data:realign_lead_partner_with_school_name"].invoke
  end

  it "updates the lead partners with the school name" do
    expect($stdout).to receive(:puts).with("Updated: 'Different Name 1' to 'Test School 1'")
    expect($stdout).to receive(:puts).with("Updated: 'Test Lead Partner 2' to 'Test School 2'")
    expect($stdout).to receive(:puts).with("Done! updated: 2 failed: 0")

    subject

    expect(lead_partner1.reload.name).to eq(school1.name)
    expect(lead_partner2.reload.name).to eq(school2.name)
    expect(lead_partner3.reload.name).to eq(school3.name)
  end
end

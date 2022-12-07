# frozen_string_literal: true

require "rails_helper"
require "csv"

describe LeadSchoolUserImport do
  let(:csv) {
    CSV.read(csv_file_path, headers: true)
  }
  let(:csv_file_path) { Rails.root.join("spec/support/fixtures/#{filename}") }
  let(:filename) { "lead_school_user_import.csv" }
  let(:csv_urns) { %w[5940019 3446713 5629417 3892190 7739792] }

  subject { described_class.call(attributes: csv) }

  context "when schools do not exist" do
    it "returns the missing URNs" do
      expect(subject).to eq(csv_urns)
    end
  end

  context "with valid data" do
    let(:first_csv_email) { "a@piltonbluecoat.devon.sch.uk" }
    let(:first_csv_urn) { "5940019" }
    let(:first_school_user) { School.find_by(urn: first_csv_urn).users.first }

    before do
      csv_urns.each do |urn|
        create(:school, :lead, urn:)
      end
    end

    it "creates users" do
      expect { subject }.to change { User.count }.from(0).to(5)
    end

    it "links users to lead schools" do
      expect { subject }.to change { LeadSchoolUser.count }.from(0).to(5)
      expect(first_school_user.email).to eq(first_csv_email)
    end
  end

  context "same user with multiple schools" do
    let(:school_one) { create(:school, :lead) }
    let(:school_two) { create(:school, :lead) }

    let(:data) do
      [
        {
          "URN" => school_one.urn,
          "First name" => "Dave",
          "Surname" => "Smith",
          "Email" => "dave@example.com",
        },
        {
          "URN" => school_two.urn,
          "First name" => "Dave",
          "Surname" => "Smith",
          "Email" => "dave@example.com",
        },
      ]
    end

    subject { described_class.call(attributes: data) }

    it "creates one user" do
      subject
      expect(User.count).to eq(1)
    end

    it "associates the user with both schools" do
      subject
      expect(User.find_by(email: "dave@example.com").lead_schools).to match_array([school_one, school_two])
    end
  end
end

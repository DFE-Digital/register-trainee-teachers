# frozen_string_literal: true

require "rails_helper"
require "tempfile"

describe "schools_data:import" do
  let(:csv) do
    Tempfile.new(["fake", ".csv"]).tap do |f|
      f.write csv_body
      f.flush
      f.close
    end
  end

  let(:csv_path) { csv.path }

  subject do
    args = Rake::TaskArguments.new([:csv_path], [csv_path])
    Rake::Task["schools_data:import"].execute(args)
  end

  context "with valid data" do
    let(:csv_body) { <<~CSV }
      urn,name,town,postcode,lead_school,open_date,close_date
      12345,Springfield Elementary,Springfield,FAKE,true,17-12-1989,""
      54321,South Park Elementary,South Park,REAL,false,13-08-1997,""
    CSV

    it "creates the schools" do
      expect { subject }.to change { School.count }.from(0).to(2)

      s1 = School.find_by_urn(12_345)
      expect(s1.name).to eq "Springfield Elementary"
      expect(s1.town).to eq "Springfield"
      expect(s1.postcode).to eq "FAKE"
      expect(s1.lead_school).to be true
      expect(s1.open_date).to eq Date.parse("17/12/1989")
      expect(s1.close_date).to be nil

      s2 = School.find_by_urn(54_321)
      expect(s2.name).to eq "South Park Elementary"
      expect(s2.town).to eq "South Park"
      expect(s2.postcode).to eq "REAL"
      expect(s2.lead_school).to be false
      expect(s2.open_date).to eq Date.parse("13/08/1997")
      expect(s2.close_date).to be nil
    end
  end

  context "with invalid data" do
    let(:csv_body) { <<~CSV }
      urn,name,town,postcode,lead_school,open_date,close_date
      12345,,Springfield,FAKE,true,17-12-1989,""
    CSV

    it "raises an exception" do
      expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

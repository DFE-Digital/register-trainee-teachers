# frozen_string_literal: true

require "rails_helper"

describe "funding_school_designations:from_upload" do
  subject(:task) { Rake::Task["funding_school_designations:from_upload"].execute(args) }

  let(:args) { Rake::TaskArguments.new(%i[upload_id academic_year], [upload.id.to_s, "2027"]) }
  let(:upload) { create(:upload, fixture_name: "funding_school_designations_import.csv") }
  let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2027) }
  let!(:school) { create(:school, urn: "100001") }

  before do
    create(:school, urn: "100002")
    create(:school, urn: "100003")
  end

  it "imports the funding school designations into the given academic cycle" do
    expect { task }.to output(/urn: 999999/).to_stdout

    expect(academic_cycle.funding_school_designations.find_by(school:)).to be_disadvantaged
  end

  context "when the academic cycle does not exist" do
    let(:args) { Rake::TaskArguments.new(%i[upload_id academic_year], [upload.id.to_s, "1990"]) }

    it "aborts without importing anything" do
      expect { task }.to raise_error(SystemExit).and output(/No academic cycle found for 1990/).to_stderr
      expect(FundingSchoolDesignation.count).to eq(0)
    end
  end
end

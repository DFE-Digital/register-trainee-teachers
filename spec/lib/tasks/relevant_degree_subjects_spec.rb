# frozen_string_literal: true

require "rails_helper"

describe "relevant_degree_subjects:from_upload" do
  subject(:task) { Rake::Task["relevant_degree_subjects:from_upload"].execute(args) }

  let(:args) { Rake::TaskArguments.new(%i[upload_id academic_year], [upload.id.to_s, "2027"]) }
  let(:upload) { create(:upload, fixture_name: "relevant_degree_subjects_import.csv") }
  let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2027) }
  let!(:mathematics) { create(:allocation_subject, name: "Mathematics") }

  before { create(:allocation_subject, name: "Physics") }

  it "imports the relevant degree subjects into the given academic cycle" do
    expect { task }.to output(/Unknown subject/).to_stdout

    expect(academic_cycle.relevant_degree_subjects.where(allocation_subject: mathematics).pluck(:hecos_code)).to contain_exactly("100403")
  end

  context "when the academic cycle does not exist" do
    let(:args) { Rake::TaskArguments.new(%i[upload_id academic_year], [upload.id.to_s, "1990"]) }

    it "aborts without importing anything" do
      expect { task }.to raise_error(SystemExit).and output(/No academic cycle found for 1990/).to_stderr
      expect(RelevantDegreeSubject.count).to eq(0)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Reports::HeQualificationsReport do
  context "given an empty list of qualifications" do
    let(:qualifications) { [] }

    it "generates a CSV with the correct headers and no rows" do
      pending "TODO"
    end
  end

  context "given a list of qualifications" do
    let(:qualifications) { Degree.all }
    let(:csv) { StringIO.new }

    before do
      @trainees = create_list(:trainee, 3, :trn_received, :with_hesa_trainee_detail)
      @trainees.each_with_index do |trainee, index|
        create_list(:degree, index + 1, :uk_degree_with_details, trainee:)
      end

      report = described_class.new(CSV.new(csv), scope: qualifications)
      report.generate_report
    end

    it "generates a CSV with the correct headers" do
      pending "TODO"
    end

    it "outputs the one row for each qualification" do
      expect(csv.string).to include("Foo")
    end
  end
end

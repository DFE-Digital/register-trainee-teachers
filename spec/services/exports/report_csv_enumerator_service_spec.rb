# frozen_string_literal: true

require "rails_helper"

describe Exports::ReportCsvEnumeratorService do
  let(:trainee) { create(:trainee, :for_export) }
  let(:trainees) do
    trainee
    Trainee.all
  end
  let(:headers) { Reports::TraineesReport.headers }
  let(:csv) { double(:csv, generate_line: "") }

  subject { described_class.call(trainees, csv) }

  describe "#call" do
    it "returns an Enumerator" do
      expect(subject).to be_an Enumerator
      expect(subject.each).to be_an Enumerator
      expect(csv).to have_received(:generate_line).exactly(0)
      expect(subject.to_a.count).to eq 2
      expect(csv).to have_received(:generate_line).exactly(2)
    end
  end
end

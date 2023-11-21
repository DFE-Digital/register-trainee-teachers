# frozen_string_literal: true

require "rails_helper"

describe Exports::BulkPlacementExport, type: :model do
  describe "#call" do
    subject(:service) { described_class.call(trainees) }

    let(:trainee) { create(:trainee) }
    let(:csv) { CSV.parse(service, headers: true) }
    let(:relevent_trainee_count) { Trainee.count }
    let(:trainees) do
      trainee
      Trainee.all
    end

    let(:expected_headers) do
      [
        "TRN",
        "Trainee ITT start date",
        "Placement 1 URN",
        "Placement 2 URN",
      ]
    end

    context "when generated" do
      it "includes a heading row and all relevant Trainees in the CSV file" do
        line_count = csv.size - 1 # bulk QTS has an extra row for the "do not edit" row
        expect(line_count).to eq(relevent_trainee_count)
      end

      it "includes the correct headers" do
        expect(csv.headers).to match_array(expected_headers)
      end
    end
  end
end

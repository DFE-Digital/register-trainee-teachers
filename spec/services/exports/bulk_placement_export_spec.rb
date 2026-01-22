# frozen_string_literal: true

require "rails_helper"

describe Exports::BulkPlacementExport, type: :model do
  describe "#call" do
    subject(:service) { described_class.call(trainees) }

    let(:trainee) { create(:trainee, :without_required_placements) }
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
        "Placement 3 URN",
        "Placement 4 URN",
        "Placement 5 URN",
      ]
    end

    let(:placement_guidance) { "If you do not know the placement school's URN, leave the cell empty." }

    let(:expected_guidance) do
      [
        "Do not change this column",
        "Do not change this column",
        "The URN of the trainee's first placement school.\n#{placement_guidance}",
        "The URN of the trainee's second placement school.\n#{placement_guidance}",
        "The URN of the trainee's third placement school.\n#{placement_guidance}",
        "The URN of the trainee's fourth placement school.\n#{placement_guidance}",
        "The URN of the trainee's fifth placement school.\n#{placement_guidance}",
      ]
    end

    context "when generated" do
      it "includes guidance row and all relevant Trainees in the CSV file" do
        line_count = csv.size - 1
        expect(line_count).to eq(relevent_trainee_count)
      end

      it "includes the expected guidance" do
        expect(csv[0].fields).to match_array(expected_guidance)
      end

      it "includes the correct headers" do
        expect(csv.headers).to match_array(expected_headers)
      end
    end
  end
end

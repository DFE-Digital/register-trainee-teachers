# frozen_string_literal: true

require "rails_helper"

describe Exports::PlacementsExport do
  describe "#call" do
    subject(:csv) { CSV.parse(described_class.call(trainees), headers: true) }

    let!(:current_cycle) { create(:academic_cycle, :current) }
    let!(:previous_cycle) { create(:academic_cycle, :previous) }
    let(:provider) { create(:provider) }
    let(:school) { create(:school, name: "Bluemeadow Secondary College", town: "Spencershire", postcode: "Y7D 4NA", urn: "594773") }
    let(:trainee) do
      create(
        :trainee,
        :provider_led_postgrad,
        :trn_received,
        :with_secondary_education,
        provider: provider,
        trn: "6800243",
        itt_start_date: Date.new(2026, 9, 16),
      )
    end
    let!(:current_placement) do
      create(
        :placement,
        :with_school,
        trainee: trainee,
        school: school,
        created_at: current_cycle.start_date + 1.day,
      )
    end
    let!(:previous_placement) do
      create(
        :placement,
        trainee: trainee,
        name: "Old School",
        urn: "111111",
        address: "1 Old Street",
        postcode: "OL1 1AA",
        created_at: previous_cycle.start_date + 1.day,
      )
    end
    let(:trainees) { provider.trainees_for_placements_report }

    let(:expected_headers) do
      [
        "TRN",
        "Trainee ITT start date",
        "Education phase",
        "Placement 1 URN",
        "Placement 1 address",
        "Placement 2 URN",
        "Placement 2 address",
        "Placement 3 URN",
        "Placement 3 address",
        "Placement 4 URN",
        "Placement 4 address",
        "Placement 5 URN",
        "Placement 5 address",
      ]
    end

    it "includes the correct headers" do
      expect(csv.headers).to eq(expected_headers)
    end

    it "includes the trainee once" do
      expect(csv.size).to eq(1)
    end

    it "includes trainee identifiers and education phase" do
      row = csv.first

      expect(row["TRN"]).to eq("6800243")
      expect(row["Trainee ITT start date"]).to eq("16/09/2026")
      expect(row["Education phase"]).to eq("Secondary")
    end

    it "includes only placements created in the current academic year" do
      row = csv.first

      expect(row["Placement 1 URN"]).to eq("594773")
      expect(row["Placement 1 address"]).to eq(
        "Bluemeadow Secondary College, URN 594773, Spencershire, Y7D 4NA",
      )
      expect(row["Placement 2 URN"]).to be_nil
      expect(row["Placement 2 address"]).to be_nil
    end

    context "when a trainee only has placements from a previous academic year" do
      let(:trainees) { Trainee.where(id: other_trainee.id) }
      let(:other_trainee) do
        create(:trainee, :provider_led_postgrad, :trn_received, provider: provider, trn: "7800243")
      end

      before do
        create(
          :placement,
          trainee: other_trainee,
          created_at: previous_cycle.start_date + 1.day,
        )
      end

      it "does not include the trainee when using the provider scope" do
        expect(provider.trainees_for_placements_report).not_to include(other_trainee)
      end
    end

    context "when a trainee has more than five current academic year placements" do
      before do
        4.times do |index|
          create(
            :placement,
            trainee: trainee,
            name: "School #{index + 2}",
            urn: "10000#{index}",
            address: "#{index + 2} Test Street",
            postcode: "TE1 #{index}AA",
            created_at: current_cycle.start_date + (index + 2).days,
          )
        end
      end

      it "includes only the first five placements by created_at" do
        row = csv.first

        expect(row["Placement 1 URN"]).to eq("594773")
        expect(row["Placement 5 URN"]).to eq("100003")
        expect(row.headers.grep(/Placement 6/)).to be_empty
      end
    end

    context "when a placement is added manually" do
      let!(:current_placement) do
        create(
          :placement,
          trainee: trainee,
          name: "Manual School",
          urn: "123456",
          address: "10 High Street",
          postcode: "M1 1AA",
          created_at: current_cycle.start_date + 1.day,
        )
      end

      it "formats the address using manual placement fields" do
        row = csv.first

        expect(row["Placement 1 URN"]).to eq("123456")
        expect(row["Placement 1 address"]).to eq(
          "Manual School, URN 123456, 10 High Street, M1 1AA",
        )
      end
    end

    context "when a placement uses a not-applicable URN" do
      let!(:current_placement) do
        create(
          :placement,
          :not_applicable_school,
          trainee: trainee,
          created_at: current_cycle.start_date + 1.day,
        )
      end

      it "includes the URN but omits the address" do
        row = csv.first

        expect(row["Placement 1 URN"]).to eq(current_placement.urn)
        expect(row["Placement 1 address"]).to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Placements
  describe ImportFromCsv do
    describe "#call" do
      let(:upload) { create(:upload, fixture_name: "placements_import.csv") }
      let!(:school1) { create(:school, urn: "137335") }
      let!(:school2) { create(:school, urn: "145787") }
      let!(:valid_unknown_school_urn) { "900000" }
      let!(:name) { I18n.t("components.placement_detail.magic_urn.#{valid_unknown_school_urn}") }
      let!(:trainee1) do
        create(
          :trainee,
          hesa_id: "0000083799785",
          itt_start_date: last_cycle.start_date,
          itt_end_date: last_cycle.end_date,
        )
      end
      let!(:trainee2) do
        create(
          :trainee,
          hesa_id: "1810078035519",
          itt_start_date: last_cycle.start_date,
          itt_end_date: last_cycle.end_date,
        )
      end
      let!(:trainee3) do
        create(
          :trainee,
          hesa_id: "2820078035529",
          itt_start_date: this_cycle.start_date,
          itt_end_date: this_cycle.end_date,
        )
      end
      let!(:trainee4) do
        create(
          :trainee,
          hesa_id: "22100027187725416",
          itt_start_date: last_cycle.start_date,
          itt_end_date: last_cycle.end_date,
        )
      end
      let(:last_cycle) { create(:academic_cycle, previous_cycle: true) }
      let(:this_cycle) { create(:academic_cycle, :current) }

      it "creates placements for each row in the csv where there are matching school and trainee" do
        expect { described_class.call(upload_id: upload.id) }
          .to change(Placement, :count).by(4)
      end

      it "creates placements with the correct attributes" do
        described_class.call(upload_id: upload.id)

        expect(Placement.pluck(:school_id).compact).to contain_exactly(
          school1.id, school2.id, school1.id
        )
        expect(Placement.pluck(:trainee_id)).to contain_exactly(
          trainee1.id, trainee2.id, trainee2.id, trainee4.id
        )
        expect(Placement.pluck(:urn).compact).to contain_exactly(
          valid_unknown_school_urn,
        )
        expect(Placement.pluck(:name).compact).to contain_exactly(
          name,
        )
      end

      it "does not create placements where there is no matching school (unless a valid HESA code)" do
        described_class.call(upload_id: upload.id)

        expect(Placement.includes([:school]).where.not(school: nil).map(&:school).map(&:urn)).not_to include("143956")
      end

      it "adds unmatched urns to the unmatched_urns array" do
        import = described_class.call(upload_id: upload.id)
        expect(import.unmatched_urns).to include("143956")
      end

      it "only creates placements for trainees in the last cycle" do
        described_class.call(upload_id: upload.id)

        expect(Placement.pluck(:trainee_id)).not_to include(trainee3.id)
      end

      it "does not create placements where trainee is in a different cycle" do
        described_class.call(upload_id: upload.id)

        expect(Placement.includes(:trainee).map(&:trainee).map(&:hesa_id)).not_to include("2010070003610")
      end

      it "creates placements where the urn is one of the HESA codes for not applicable school URNs" do
        described_class.call(upload_id: upload.id)

        expect(Placement.where(urn: valid_unknown_school_urn).first.trainee_id).to eq(trainee4.id)
      end

      context "matching placement already exists" do
        before do
          create(:placement, school: school1, trainee: trainee1)
          create(:placement, school: school2, trainee: trainee2)
          create(:placement, school: school1, trainee: trainee2)
          create(:placement, urn: valid_unknown_school_urn, name: name, trainee: trainee4)
        end

        it "does not create duplicate placements" do
          expect { described_class.call(upload_id: upload.id) }
            .not_to change(Placement, :count)
        end
      end
    end
  end
end

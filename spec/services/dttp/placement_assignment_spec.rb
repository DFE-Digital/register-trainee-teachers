# frozen_string_literal: true

require "rails_helper"
module Dttp
  describe PlacementAssignment do
    let(:programme_start_date) { 1.year.ago }
    let(:programme_end_date) { Time.zone.now }
    let(:placement_assignment_id) { SecureRandom.uuid }
    let(:provider_id_value) { SecureRandom.uuid }

    let(:placement_assignment_json) do
      {
        dfe_programmestartdate: programme_start_date,
        dfe_programmeenddate: programme_end_date,
        dfe_placementassignmentid: placement_assignment_id,
        _dfe_providerid_value: provider_id_value,
      }
    end

    subject { described_class.new(placement_assignment_json: placement_assignment_json) }

    describe "instance methods" do
      it "#programme_start_dates" do
        expect(subject.programme_start_date).to eq(programme_start_date)
      end

      it "#programme_end_dates" do
        expect(subject.programme_end_date).to eq(programme_end_date)
      end

      it "#placement_assignment_id" do
        expect(subject.placement_assignment_id).to eq(placement_assignment_id)
      end

      it "#provider_id_value" do
        expect(subject.provider_id_value).to eq(provider_id_value)
      end
    end
  end
end

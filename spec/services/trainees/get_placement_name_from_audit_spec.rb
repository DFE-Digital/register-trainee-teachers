# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe GetPlacementNameFromAudit do
    let(:trainee) { create(:trainee) }
    let(:school) { create(:school) }
    let(:new_school) { create(:school) }

    let(:placement) { create(:placement, school:, trainee:) }

    context "when the placement is associated with a school record" do
      it "returns the correct names for a create audit" do
        placement
        audit = Audited::Audit.where(auditable_type: "Placement", action: :create).last
        expect(described_class.call(audit:)).to eq(placement.name)
      end

      it "returns the correct names for a destroy audit" do
        old_name = placement.name
        placement.destroy!

        audit = Audited::Audit.where(auditable_type: "Placement", action: :destroy).last
        expect(described_class.call(audit:)).to eq(old_name)
      end

      it "returns the correct names for an update audit" do
        old_name = placement.name
        placement.update!(school: create(:school))

        audit = Audited::Audit.where(auditable_type: "Placement", action: :update).last
        expect(described_class.call(audit:)).to eq([old_name, placement.name])
      end

      it "returns 'Unknown School' if the previous school doesn't exist any more" do
        placement.update!(school: create(:school))
        school.destroy!

        audit = Audited::Audit.where(auditable_type: "Placement", action: :update).last
        expect(described_class.call(audit:)).to eq(["Unknown school", placement.name])
      end

      it "returns 'Unknown School' if the current school doesn't exist any more" do
        placement.update!(school: new_school)
        new_school.destroy!

        audit = Audited::Audit.where(auditable_type: "Placement", action: :update).last
        expect(described_class.call(audit:)).to eq([school.name, "Unknown school"])
      end
    end

    context "when the placement is NOT associated with a school record" do
      let(:placement) { create(:placement, trainee:) }

      it "returns the correct names for a create audit" do
        placement
        audit = Audited::Audit.where(auditable_type: "Placement", action: :create).last
        expect(described_class.call(audit:)).to eq(placement.name)
      end

      it "returns the correct names for a destroy audit" do
        old_name = placement.name
        placement.destroy!

        audit = Audited::Audit.where(auditable_type: "Placement", action: :destroy).last
        expect(described_class.call(audit:)).to eq(old_name)
      end

      it "returns the correct names for an update audit" do
        old_name = placement.name
        placement.update!(name: "St. Bob's Academy")

        audit = Audited::Audit.where(auditable_type: "Placement", action: :update).last
        expect(described_class.call(audit:)).to eq([old_name, "St. Bob's Academy"])
      end
    end
  end
end

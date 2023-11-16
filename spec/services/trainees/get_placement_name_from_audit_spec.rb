# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe GetPlacementNameFromAudit do
    let(:trainee) { create(:trainee) }
    let(:placement) { create(:placement, trainee:) }

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
    end

    context "when the placement is NOT associated with a school record" do
      let(:placement) { create(:placement, :manual, trainee:) }

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

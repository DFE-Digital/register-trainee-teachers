# frozen_string_literal: true

require "rails_helper"

describe PlacementsImportedFromHesa do
  let(:trainee) { create(:trainee, :with_placements) }

  subject { described_class.call(trainee:) }

  context "when the trainee is not imported from HESA" do
    it { is_expected.to be(false) }
  end

  context "when the trainee is imported from HESA but not all placements are" do
    let(:trainee) { create(:trainee, :with_placements, :imported_from_hesa) }

    it { is_expected.to be(false) }
  end

  context "when the trainee and all it's placements is imported from HESA but not all placements are" do
    let(:trainee) do
      Audited.audit_class.as_user(Trainee::HESA_USERNAME) do
        create(:trainee, :with_placements, :imported_from_hesa)
      end
    end

    it { is_expected.to be(true) }
  end
end

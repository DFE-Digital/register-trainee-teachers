# frozen_string_literal: true

require "rails_helper"

describe DestroyPlacementForm, type: :model do
  let(:trainee) { create(:trainee) }
  let!(:placement) { create(:placement) }
  let(:placements_form) { PlacementsForm.new(trainee) }
  let(:slug) { placement.slug }

  subject(:form) { described_class.find_from_param(placements_form:, slug:) }

  describe "#mark_for_destruction!" do
    context "when the given id is for a placement for the given trainee" do
      let!(:placement) { create(:placement, trainee:) }

      it "only deletes the placement in temporary state" do
        expect { form.mark_for_destruction! }.not_to change { trainee.placements.count }
      end
    end

    context "when the given id is for a placement for a different trainee" do
      it "does NOT delete the placement and throws an exception" do
        expect { form.mark_for_destruction! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

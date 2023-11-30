# frozen_string_literal: true

require "rails_helper"

describe DestroyPlacementForm, type: :model do
  let!(:placement) { create(:placement, trainee:) }
  let(:placements_form) { PlacementsForm.new(trainee) }
  let(:slug) { placement.slug }

  subject(:form) { described_class.find_from_param(placements_form:, slug:) }

  describe "#destroy_or_stash!" do
    context "when the given slug is for a placement that is not present in the database" do
      let(:trainee) { create(:trainee, :draft) }

      it "deletes the placement in temporary state" do
        expect(placements_form).to receive(:delete_placement_on_store).with(slug)
        expect { form.destroy_or_stash! }.to change { trainee.placements.count }.by(-1)
      end
    end

    context "when the given slug is for a placement for the given draft trainee" do
      let(:trainee) { create(:trainee, :draft) }

      it "deletes the placement in temporary and persistent state" do
        expect(placements_form).to receive(:delete_placement_on_store).with(slug)
        expect { form.destroy_or_stash! }.to change { trainee.placements.count }.by(-1)
      end
    end

    context "when the given slug is for a placement for the given registered trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      it "only marks the placement for deletion in temporary state" do
        expect(placements_form).not_to receive(:delete_placement_on_store).with(slug)
        expect { form.destroy_or_stash! }.not_to change { trainee.placements.count }
      end
    end
  end
end

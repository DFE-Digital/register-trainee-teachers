# frozen_string_literal: true

require "rails_helper"

describe DestroyPlacementForm, type: :model do
  let(:trainee) { create(:trainee) }
  let!(:placement) { create(:placement) }

  subject(:form) { DestroyPlacementForm.find_from_param(trainee, placement.id.to_s) }

  describe "#destroy!" do
    context "when the given id is for a placement for the given trainee" do
      let!(:placement) { create(:placement, trainee:) }

      it "deletes the placement" do
        expect { form.destroy! }.to change { trainee.placements.count }.by(-1)
      end
    end

    context "when the given id is for a placement for a different trainee" do
      it "does NOT delete the placement" do
        expect { form.destroy! }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

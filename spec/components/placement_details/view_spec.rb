# frozen_string_literal: true

require "rails_helper"

module PlacementDetails
  describe View do
    let(:trainee) { create(:trainee, :imported_from_hesa) }

    context "when placements come from hesa" do
      let!(:placements) { create_list(:placement, 2, trainee:) }

      before do
        render_inline(View.new(trainee:))
      end

      it "shows the placement details" do
        trainee.placements.each do |placement|
          expect(rendered_component).to have_text(placement.name)
          expect(rendered_component).to have_text(placement.full_address)
        end
      end
    end

    context "when placements are added manually" do
      let!(:placements) { create_list(:placement, 2, :manual, trainee:) }

      before do
        render_inline(View.new(trainee:))
      end

      it "shows the placement details" do
        trainee.placements.each do |placement|
          expect(rendered_component).to have_text(placement.name)
          expect(rendered_component).to have_text(placement.full_address)
        end
      end
    end
  end
end

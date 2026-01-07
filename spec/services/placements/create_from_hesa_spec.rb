# frozen_string_literal: true

require "rails_helper"

module Placements
  describe CreateFromHesa do
    let(:hesa_api_stub) { ApiStubs::HesaApi.new }
    let(:student_attributes) { hesa_api_stub.student_attributes }
    let(:trainee) { create(:trainee, hesa_id: student_attributes[:hesa_id]) }
    let(:hesa_placements) { student_attributes[:placements] }

    subject(:create_from_hesa) do
      described_class.call(trainee:, hesa_placements:)
    end

    shared_examples "invalid" do
      it "does not save the placement" do
        expect { create_from_hesa }.not_to change(trainee.placements, :count)
      end
    end

    context "update trainee with HESA XML" do
      let(:student_attributes) { hesa_api_stub.student_attributes.merge(placements: [hesa_placement]) }
      let(:hesa_placement) { { school_urn: valid_school.urn, placement_days: "160" } }
      let(:valid_school) { create(:school) }

      before do
        create_from_hesa
      end

      it "creates the exact number of placements as specified in the XML" do
        expect(trainee.placements.count).to eq(student_attributes[:placements].count)
      end

      context "when the school urn is among NOT_APPLICABLE_SCHOOL_URNS" do
        let(:hesa_placement) { { school_urn: School::NOT_APPLICABLE_SCHOOL_URNS.sample, placement_days: "160" } }

        it "creates the placement" do
          expect(trainee.placements.count).to eq(student_attributes[:placements].count)
        end

        it "stores the name" do
          expect(trainee.placements.first.name).to eq(I18n.t("components.placement_detail.magic_urn.#{hesa_placement[:school_urn]}"))
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module HesaWarningInset
  describe View, type: :component do
    let(:current_user) do
      double(UserWithOrganisationContext, provider?: true)
    end

    subject(:component) do
      described_class.new(trainee:, current_user:)
    end

    context "for non-HESA trainee" do
      let(:trainee) { build(:trainee) }

      it "renders nothing" do
        render_inline(component)

        expect(rendered_component).to be_blank
      end
    end

    context "for HESA trainee" do
      let(:trainee) do
        build(
          :trainee,
          :imported_from_hesa,
          hesa_updated_at: Time.zone.local(2023, 1, 11, 12, 34, 56),
          hesa_editable: editable,
        )
      end

      context "when trainee is not editable" do
        let(:editable) { false }

        it "renders HESA warning message" do
          render_inline(component)

          expect(rendered_component).to include("This trainee was imported from HESA. You can recommend, defer or withdraw them. You need to enable editing to make other changes.")
        end

        it "renders last update date and time" do
          render_inline(component)

          expect(rendered_component).to include("Last updated from HESA on 11 January 2023 at 12:34pm")
        end
      end

      context "when trainee is editable" do
        let(:editable) { true }

        it "renders HESA warning message" do
          render_inline(component)

          expect(rendered_component).to include("Editing has been enabled for this trainee. The record is still linked to the HESA service. If you update it using HESA then any changes you’ve made in this service will be replaced by the data from HESA.")
        end

        it "renders last update date and time" do
          render_inline(component)

          expect(rendered_component).to include("Last updated from HESA on 11 January 2023 at 12:34pm")
        end
      end
    end
  end
end

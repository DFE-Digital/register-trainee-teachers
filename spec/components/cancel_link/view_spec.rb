# frozen_string_literal: true

require "rails_helper"

module CancelLink
  describe View do
    alias_method :component, :page

    describe "rendering" do
      before do
        render_inline(described_class.new(trainee))
      end

      context "when the trainee is a non draft" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }

        it "renders the record page link" do
          expect(component).to have_link(t("cancel"), href: "/trainees/#{trainee.slug}")
        end
      end

      context "when the trainee is a draft" do
        let(:trainee) { build(:trainee, :draft) }

        it "does not render the component" do
          expect(component).not_to have_css("body")
        end
      end
    end
  end
end

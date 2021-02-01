# frozen_string_literal: true

require "rails_helper"

module DynamicBackLink
  describe View do
    alias_method :component, :page

    let(:session) { {} }

    before do
      render_inline(described_class.new(trainee))
    end

    context "draft trainee" do
      let(:trainee) { create(:trainee, :draft) }

      it "renders a back link" do
        expect(component).to have_link(t("back_to_draft"), href: "/trainees/#{trainee.to_param}/review-draft")
      end
    end

    context "draft trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      it "renders a back link" do
        expect(component).to have_link(t("back_to_record"), href: "/trainees/#{trainee.to_param}")
      end
    end
  end
end

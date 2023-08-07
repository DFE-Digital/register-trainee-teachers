# frozen_string_literal: true

require "rails_helper"

module AwardDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:show_undo_award) { false }
    let(:view) { View.new(trainee, show_undo_award:) }

    before do
      render_inline(view)
    end

    context "when trainee has been awarded" do
      let(:trainee) { build(:trainee, :awarded) }

      it "renders the award date" do
        expect(component.find(summary_card_row_for("award-date"))).to have_text(date_for_summary_view(trainee.awarded_at))
      end

      it "does not render undo award link" do
        expect(component).not_to have_link("Remove QTS award")
      end
    end

    context "when trainee is recommended for award" do
      let(:trainee) { build(:trainee, :recommended_for_award, recommended_for_award_at: 10.days.ago) }

      it "renders recommended date if awaiting award" do
        expect(component.find(summary_card_row_for("award-date"))).to have_text(
          "Waiting for award - met standards on #{date_for_summary_view(trainee.recommended_for_award_at)}",
        )
      end
    end

    context "when option to render undo award link is true" do
      let(:trainee) { build(:trainee, :awarded) }
      let(:show_undo_award) { true }

      it "renders undo award link" do
        expect(component).to have_link("Remove QTS award")
      end
    end
  end
end

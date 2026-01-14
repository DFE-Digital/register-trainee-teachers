# frozen_string_literal: true

require "rails_helper"

module AwardDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    before do
      render_inline(View.new(trainee))
    end

    context "when trainee has been awarded" do
      let(:trainee) { build(:trainee, :awarded) }

      it "renders the award date" do
        expect(component.find(summary_card_row_for("status"))).to have_text(date_for_summary_view(trainee.awarded_at))
      end
    end

    context "when trainee is recommended for award" do
      let(:trainee) { build(:trainee, :recommended_for_award, recommended_for_award_at: 10.days.ago, outcome_date: 20.days.ago) }

      it "renders recommended date if awaiting award" do
        expect(component.find(summary_card_row_for("status"))).to have_text(
          "QTS/EYTS pending since #{date_for_summary_view(trainee.outcome_date)}",
        )
      end
    end
  end
end

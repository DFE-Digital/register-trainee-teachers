# frozen_string_literal: true

require "rails_helper"

module AwardDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:trainee) { build(:trainee, :awarded) }

    before do
      render_inline(View.new(trainee))
    end

    it "renders the award date" do
      expect(component.find(summary_card_row_for("award-date"))).to have_text(date_for_summary_view(trainee.awarded_at))
    end
  end
end

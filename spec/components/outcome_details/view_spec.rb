# frozen_string_literal: true

require "rails_helper"

module OutcomeDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:trainee) { build(:trainee, :with_outcome_date) }
    let(:data_model) { OpenStruct.new(trainee: trainee, date: trainee.outcome_date) }

    before do
      render_inline(View.new(data_model))
    end

    it "renders the outcome end date" do
      expect(component.find(summary_card_row_for("date-standards-met"))).to have_text(date_for_summary_view(data_model.date))
    end
  end
end

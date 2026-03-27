# frozen_string_literal: true

require "rails_helper"

module OutcomeDetails
  describe View do
    include SummaryHelper

    alias_method :component, :page

    let(:trainee) { build(:trainee, :with_outcome_date) }
    let(:data_model) { OpenStruct.new(trainee: trainee, date: trainee.outcome_date, date_string: "other") }

    before do
      render_inline(View.new(data_model))
    end

    it "renders the outcome date" do
      expect(component).to have_text(date_for_summary_view(data_model.date))
    end

    it "renders the summary list row key" do
      expect(component).to have_text("When did the trainee’s #{trainee.award_type} status change?")
    end
  end
end

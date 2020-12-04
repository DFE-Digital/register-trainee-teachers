# frozen_string_literal: true

require "rails_helper"

module Trainees
  module OutcomeDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:trainee) { OpenStruct.new(outcome_date: Time.zone.yesterday) }

      before do
        render_inline(View.new(trainee))
      end

      it "renders the outcome end date" do
        expect(component.find(summary_card_row_for("date-standards-met"))).to have_text(date_for_summary_view(trainee.outcome_date))
      end
    end
  end
end

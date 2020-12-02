# frozen_string_literal: true

require "rails_helper"

module Trainees
  module AssessmentDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:trainee) { OpenStruct.new(assessment_outcome: "passed", assessment_end_date: Time.zone.yesterday) }

      before do
        render_inline(View.new(trainee))
      end

      it "renders the assessment outcome" do
        expect(component.find(summary_card_row_for("assessment-outcome"))).to have_text(trainee.assessment_outcome.humanize)
      end

      it "renders the assessment end date" do
        expect(component.find(summary_card_row_for("assessment-end-date"))).to have_text(date_for_summary_view(trainee.assessment_end_date))
      end
    end
  end
end

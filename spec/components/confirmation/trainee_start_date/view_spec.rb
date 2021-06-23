# frozen_string_literal: true

require "rails_helper"

module Confirmation
  module TraineeStartDate
    describe View do
      include SummaryHelper

      alias_method :component, :page

      let(:commencement_date) { Time.zone.today }

      context "when data has been provided" do
        let(:trainee) { create(:trainee, commencement_date: commencement_date) }

        before do
          render_inline(View.new(data_model: trainee))
        end

        it "renders the trainee start date" do
          expect(trainee_start_date).to have_text(date_for_summary_view(commencement_date))
        end
      end

      def trainee_start_date
        component.find(".govuk-summary-list__row.start-date .govuk-summary-list__value")
      end
    end
  end
end

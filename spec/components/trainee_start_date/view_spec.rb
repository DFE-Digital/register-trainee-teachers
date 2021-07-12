# frozen_string_literal: true

require "rails_helper"

module TraineeStartDate
  describe View do
    include SummaryHelper

    let(:commencement_date) { Time.zone.today }

    context "when data has been provided" do
      let(:trainee) { create(:trainee, commencement_date: commencement_date) }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "renders the trainee start date" do
        expect(rendered_component).to have_text(date_for_summary_view(commencement_date))
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module TraineeStartDate
  describe View do
    include SummaryHelper

    let(:trainee_start_date) { Time.zone.today }

    context "when data has been provided" do
      let(:trainee) { create(:trainee, trainee_start_date:) }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "renders the trainee start date" do
        expect(page).to have_text(date_for_summary_view(trainee_start_date))
      end
    end
  end
end

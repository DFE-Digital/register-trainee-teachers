# frozen_string_literal: true

require "rails_helper"

module TraineeStartStatus
  describe View do
    include SummaryHelper

    let(:commencement_date) { Time.zone.today }
    let(:trainee) { create(:trainee, commencement_date: commencement_date) }

    before do
      render_inline(View.new(data_model: trainee))
    end

    context "when data has been provided" do
      it "renders the trainee start date" do
        expect(rendered_component).to have_text(date_for_summary_view(commencement_date))
      end
    end

    context "when the trainee has not started their itt" do
      let(:trainee) { create(:trainee, commencement_status: :itt_not_yet_started) }

      it "renders not started yet text" do
        expect(rendered_component).to have_text("Trainee has not started yet")
      end
    end
  end
end

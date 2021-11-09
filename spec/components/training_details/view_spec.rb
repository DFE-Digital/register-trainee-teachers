# frozen_string_literal: true

require "rails_helper"

module TrainingDetails
  describe View do
    include SummaryHelper

    describe "when the data isn't provided" do
      let(:trainee) { build(:trainee) }

      before do
        trainee.trainee_id = nil
        render_inline(View.new(data_model: trainee))
      end

      it "tells the user that the data is missing" do
        expect(rendered_component).to have_text(t("components.confirmation.missing"), count: 1)
      end
    end

    describe "when the data is provided" do
      let(:trainee) { build(:trainee) }

      before do
        trainee.trainee_id = "some id"
        render_inline(View.new(data_model: trainee))
      end

      it "renders the trainee_id" do
        expect(rendered_component).to have_text(trainee.trainee_id)
      end

      context "when trainee has a hpitt_provider" do
        let(:trainee) { build(:trainee, :with_hpitt_provider) }

        it "renders the trainee's region" do
          expect(rendered_component).to have_text(trainee.region)
        end
      end
    end
  end
end

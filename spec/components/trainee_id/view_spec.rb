# frozen_string_literal: true

require "rails_helper"

module TraineeId
  describe View do
    alias_method :component, :page

    context "when data has been provided" do
      let(:trainee) { create(:trainee) }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "renders the trainee ID" do
        expect(rendered_component).to have_text(trainee.trainee_id)
      end
    end
  end
end

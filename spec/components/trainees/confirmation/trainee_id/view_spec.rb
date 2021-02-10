# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module TraineeId
      describe View do
        alias_method :component, :page

        context "when data has been provided" do
          let(:trainee) { create(:trainee) }

          before do
            render_inline(View.new(trainee: trainee))
          end

          it "renders the trainee ID" do
            expect(trainee_id_row).to have_text(trainee.trainee_id)
          end
        end

        def trainee_id_row
          component.find(".govuk-summary-list__row.trainee-id .govuk-summary-list__value")
        end
      end
    end
  end
end

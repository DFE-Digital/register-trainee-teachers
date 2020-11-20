# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module Record
      describe View do
        alias_method :component, :page

        context "when data has not been provided" do
          # let(:trainee) { build(:trainee, id: 1, subject: nil, age_range: nil, programme_start_date: nil) }

          before do
            render_inline(View.new(trainee: Trainee.new))
          end

          it "tells the user that no data has been entered for Type of training and trainee ID" do
            found = component.find_all(".govuk-summary-list__row")

            expect(found.size).to eq(2)

            found.each do |row|
              expect(row.find(".govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
            end
          end
        end

        context "when data has been provided" do
          let(:trainee) { build(:trainee) }

          before do
            render_inline(View.new(trainee: trainee))
          end

          it "renders the type of training" do
            expect(component.find(".govuk-summary-list__row.type-of-training .govuk-summary-list__value"))
              .to have_text(trainee.record_type.humanize)
          end

          it "renders the trainee ID" do
            expect(component.find(".govuk-summary-list__row.trainee-id .govuk-summary-list__value"))
              .to have_text(trainee.trainee_id)
          end
        end
      end
    end
  end
end

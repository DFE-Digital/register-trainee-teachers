# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Confirmation
    module CourseDetails
      describe View do
        alias_method :component, :page

        context "when data has not been provided" do
          let(:trainee) { build(:trainee, id: 1, training_route: nil, subject: nil, age_range: nil, course_start_date: nil) }
          before do
            render_inline(View.new(data_model: trainee))
          end

          it "tells the user that no data has been entered for course type, subject, age range, course start date and course end date" do
            found = component.find_all(".govuk-summary-list__row")

            expect(found.size).to eq(5)

            found.each do |row|
              expect(row.find(".govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
            end
          end
        end

        context "when data has been provided" do
          let(:trainee) { build(:trainee, :with_course_details, id: 1) }

          before do
            render_inline(View.new(data_model: trainee))
          end

          it "renders the course type" do
            expect(component.find(".govuk-summary-list__row.type-of-course .govuk-summary-list__value"))
              .to have_text(trainee.training_route.humanize)
          end

          it "renders the subject" do
            expect(component.find(".govuk-summary-list__row.subject .govuk-summary-list__value"))
              .to have_text(trainee.subject)
          end

          it "renders the age range" do
            expect(component.find(".govuk-summary-list__row.age-range .govuk-summary-list__value"))
              .to have_text(trainee.age_range)
          end

          it "renders the course start date" do
            expect(component.find(".govuk-summary-list__row.course-start-date .govuk-summary-list__value"))
              .to have_text(trainee.course_start_date.strftime("%-d %B %Y"))
          end
        end
      end
    end
  end
end

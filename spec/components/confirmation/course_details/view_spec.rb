# frozen_string_literal: true

require "rails_helper"

module Confirmation
  module CourseDetails
    describe View do
      include SummaryHelper

      alias_method :component, :page

      context "when data has not been provided" do
        let(:trainee) do
          build(:trainee, id: 1,
                          training_route: nil,
                          course_subject_one: nil,
                          course_code: nil,
                          course_min_age: nil,
                          course_max_age: nil,
                          course_start_date: nil)
        end

        before do
          render_inline(View.new(data_model: trainee))
        end

        it "tells the user that no data has been entered for course details, course type, subject, age range, course start date and course end date" do
          found = component.find_all(".govuk-summary-list__row")

          expect(found.size).to eq(5)

          found.at(1..5).each do |row|
            expect(row.find(".govuk-summary-list__value")).to have_text(t("components.confirmation.not_provided"))
          end
        end
      end

      context "when data has been provided" do
        context "with a publish course", feature_publish_course_details: true do
          let(:trainee) { create(:trainee, :with_course_details, :with_related_courses, courses_count: 1) }
          let(:course) { instance_double("course", name: "some_name", code: "some_code") }

          before do
            expect(Course).to receive(:find_by).with(code: trainee.course_code).and_return(course)
            render_inline(View.new(data_model: trainee))
          end

          it "renders the course details" do
            expect(component.find(".govuk-summary-list__row.course-details .govuk-summary-list__value"))
              .to have_text("#{course.name} (#{course.code})")
          end

          it "renders the course type" do
            expect(component.find(".govuk-summary-list__row.route .govuk-summary-list__value"))
              .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
          end

          it "renders the subject" do
            expect(component.find(".govuk-summary-list__row.subject .govuk-summary-list__value"))
              .to have_text(trainee.course_subject_one.upcase_first)
          end

          it "renders the course age range" do
            expect(component.find(".govuk-summary-list__row.age-range .govuk-summary-list__value"))
              .to have_text(age_range_for_summary_view(trainee.course_age_range))
          end

          it "renders the course start date" do
            expect(component.find(".govuk-summary-list__row.course-start-date .govuk-summary-list__value"))
              .to have_text(date_for_summary_view(trainee.course_start_date))
          end
        end

        context "without a publish course" do
          let(:trainee) { create(:trainee) }

          before do
            render_inline(View.new(data_model: trainee))
          end

          it "doesn't render course details information" do
            expect(component).not_to have_selector(".govuk-summary-list__row.course-details")
          end
        end
      end

      context "early years route" do
        before do
          render_inline(View.new(data_model: trainee))
        end

        context "non draft" do
          let(:trainee) { create(:trainee, :early_years_undergrad, :with_course_details, :submitted_for_trn) }

          it "renders route" do
            expect(component).to have_text("Route")
            expect(component.find(".govuk-summary-list__row.route .govuk-summary-list__value"))
              .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
          end
        end

        context "non draft" do
          let(:trainee) { create(:trainee, :early_years_undergrad, :with_course_details, :draft) }

          it "does not render route" do
            expect(component).not_to have_text("Route")
            expect(component).not_to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
          end
        end
      end

      context "non early years route (assessment only)" do
        before do
          render_inline(View.new(data_model: trainee))
        end

        context "draft" do
          let(:trainee) { create(:trainee, :with_course_details, :draft) }

          it "renders route" do
            expect(component).to have_text("Route")
            expect(component.find(".govuk-summary-list__row.route .govuk-summary-list__value"))
              .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
          end
        end

        context "non draft" do
          let(:trainee) { create(:trainee, :with_course_details, :submitted_for_trn) }

          it "renders route" do
            expect(component).to have_text("Route")
            expect(component.find(".govuk-summary-list__row.route .govuk-summary-list__value"))
              .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
          end
        end
      end
    end
  end
end

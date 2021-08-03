# frozen_string_literal: true

require "rails_helper"

module CourseDetails
  describe View do
    include SummaryHelper

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
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 6)
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: t("components.confirmation.not_provided"), count: 6)
      end
    end

    context "when data has been provided" do
      context "with a publish course", feature_publish_course_details: true do
        let(:trainee) { create(:trainee, :with_course_details, :with_related_courses, courses_count: 1) }
        let(:course) { instance_double("course", name: "some_name", code: "some_code") }

        before do
          allow(Course).to receive(:find_by).with(code: trainee.course_code).and_return(course)
          render_inline(View.new(data_model: trainee))
        end

        it "renderendered_rs the course details" do
          expect(rendered_component)
            .to have_text("#{course.name} (#{course.code})")
        end

        it "renderendered_rs the course type" do
          expect(rendered_component)
            .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
        end

        it "rendrendered_ers the subject" do
          expect(rendered_component)
            .to have_text(trainee.course_subject_one.upcase_first)
        end

        it "renderendered_rs the course age range" do
          expect(rendered_component)
            .to have_text(age_range_for_summary_view(trainee.course_age_range))
        end

        it "renderendered_rs the course start date" do
          expect(rendered_component)
            .to have_text(date_for_summary_view(trainee.course_start_date))
        end
      end

      context "without a publish course" do
        let(:trainee) { create(:trainee) }

        before do
          render_inline(View.new(data_model: trainee))
        end

        it "doesn't render course details information" do
          expect(rendered_component).not_to have_selector(".govuk-summary-list__row.course-details")
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
          expect(rendered_component).to have_text("Route")
          expect(rendered_component)
            .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
        end
      end

      context "draft" do
        let(:trainee) { create(:trainee, :early_years_undergrad, :with_course_details, :draft) }

        it "does not render route" do
          expect(rendered_component).not_to have_text("Route")
          expect(rendered_component).not_to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
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
          expect(rendered_component).to have_text("Route")
          expect(rendered_component)
            .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
        end
      end

      context "non draft" do
        let(:trainee) { create(:trainee, :with_course_details, :submitted_for_trn) }

        it "renders route" do
          expect(rendered_component).to have_text("Route")
          expect(rendered_component)
            .to have_text(t("activerecord.attributes.trainee.training_routes.#{trainee.training_route}"))
        end
      end
    end

    context "route with study_mode" do
      let(:trainee) { create(:trainee, :provider_led_postgrad, study_mode: "full_time") }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "renders study_mode" do
        expect(rendered_component).to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__key", text: "Full time or part time")
        expect(rendered_component).to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__value", text: "Full time")
      end
    end

    context "route without study_mode" do
      let(:trainee) { create(:trainee, :early_years_undergrad, study_mode: nil) }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "does not render study_mode" do
        expect(rendered_component).not_to have_selector(".govuk-summary-list__row.full-time-or-part-time")
      end
    end
  end
end

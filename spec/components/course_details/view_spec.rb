# frozen_string_literal: true

require "rails_helper"

module CourseDetails
  describe View do
    include SummaryHelper

    let(:training_route) { "Training route" }
    let(:education_phase) { "Education phase" }
    let(:age_range) { "Age range" }

    context "when data has not been provided" do
      let(:trainee) do
        build(:trainee, id: 1,
                        training_route: nil,
                        course_subject_one: nil,
                        course_uuid: nil,
                        course_min_age: nil,
                        course_max_age: nil,
                        itt_start_date: nil)
      end

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "renders 6 rows" do
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 6)
      end

      it "renders missing hint education phase" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "Education phase is missing")
      end

      it "renders missing hint for subject" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "Subject is missing")
      end

      it "renders missing hint for age range" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "Age range is missing")
      end

      it "renders missing hint for ITT start date" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "ITT start date is missing")
      end

      it "renders missing hint for ITT end date" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "ITT end date is missing")
      end
    end

    context "with an apply draft, and missing data" do
      let(:trainee) do
        create(:trainee,
               :provider_led_postgrad,
               :with_publish_course_details,
               :with_apply_application,
               course_subject_one: nil,
               course_min_age: nil,
               course_max_age: nil,
               itt_start_date: nil,
               itt_end_date: nil)
      end
      let(:specialisms) { ["Spanish language", "public services"] }

      let(:data_model) { ::ApplyApplications::ConfirmCourseForm.new(trainee, specialisms, { uuid: course.uuid }) }

      let(:course) { trainee.published_course }

      before do
        render_inline(View.new(data_model: data_model))
      end

      it "calculated/applicable specialisms for subject" do
        expect(rendered_component).to have_selector(".govuk-summary-list__value", text: "Spanish with public services")
      end

      it "renders the course age range" do
        expect(rendered_component)
          .to have_text(age_range_for_summary_view(course.age_range))
      end
    end

    context "when data has been provided" do
      context "with a publish course", feature_publish_course_details: true do
        let(:trainee) { create(:trainee, :with_primary_education, :with_publish_course_details) }

        before do
          render_inline(View.new(data_model: trainee))
        end

        it "renders the correct course details" do
          expect(rendered_component)
            .to have_text("#{trainee.published_course.name} (#{trainee.published_course.code})")
        end

        it "renders the education phase" do
          expect(rendered_component)
            .to have_text(trainee.course_education_phase.upcase_first)
        end

        it "renders the education change phase link" do
          expect(rendered_component)
            .to have_link(t("change"), href: "/trainees/#{trainee.slug}/course-education-phase/edit")
        end

        it "renders the subject" do
          expect(rendered_component).to have_text(trainee.course_subject_one.upcase_first)
        end

        it "renders the course age range" do
          expect(rendered_component).to have_text(age_range_for_summary_view(trainee.course_age_range))
        end

        it "renders the ITT start date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.itt_start_date))
        end

        it "renders the ITT end date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.itt_end_date))
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
        let(:trainee) { create(:trainee, :early_years_undergrad, :with_early_years_course_details, :submitted_for_trn) }

        it "renders the training route" do
          expect(rendered_component).to have_text(training_route)
        end

        it "does not render education phase" do
          expect(rendered_component).not_to have_text(education_phase)
        end

        it "does not render course age range" do
          expect(rendered_component).not_to have_text(age_range)
        end
      end

      context "draft" do
        let(:trainee) { create(:trainee, :early_years_undergrad, :with_early_years_course_details, :draft) }

        it "does not render the training route" do
          expect(rendered_component).not_to have_text(training_route)
        end

        it "does not render education phase" do
          expect(rendered_component).not_to have_text(education_phase)
        end
      end
    end

    context "non early years route (assessment only)" do
      before do
        render_inline(View.new(data_model: trainee))
      end

      context "draft" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :draft) }

        it "does not render the training route" do
          expect(rendered_component).not_to have_text(training_route)
        end

        it "renders route" do
          expect(rendered_component).to have_text(education_phase)
          expect(rendered_component)
            .to have_text("Secondary")
        end

        it "renders course age range" do
          expect(rendered_component).to have_text(age_range)
        end
      end

      context "non draft" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :submitted_for_trn) }

        it "renders the training route" do
          expect(rendered_component).to have_text(training_route)
        end

        it "renders route" do
          expect(rendered_component).to have_text(education_phase)
          expect(rendered_component)
            .to have_text("Secondary")
        end

        it "renders course age range" do
          expect(rendered_component).to have_text(age_range)
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
      let(:trainee) { create(:trainee, :assessment_only, study_mode: nil) }

      before do
        render_inline(View.new(data_model: trainee))
      end

      it "does not render study_mode" do
        expect(rendered_component).not_to have_selector(".govuk-summary-list__row.full-time-or-part-time")
      end
    end
  end
end

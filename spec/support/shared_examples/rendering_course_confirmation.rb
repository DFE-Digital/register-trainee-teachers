# frozen_string_literal: true

RSpec.shared_examples "rendering course confirmation" do
  let(:trainee) { build(:trainee, :provider_led_postgrad, study_mode: "full_time") }
  let(:itt_start_date) { nil }

  let(:args) do
    if described_class == PublishCourseDetails::View
      {
        trainee: trainee,
        course: course,
        specialisms: specialisms,
        itt_start_date: itt_start_date,
        course_study_mode: "full_time",
      }
    else
      {
        trainee: trainee,
        course: course,
        specialisms: specialisms,
        itt_start_date: itt_start_date,
      }
    end
  end

  context "default behaviour" do
    let(:course) { build(:course, duration_in_years: 2) }
    let(:specialisms) { ["Specialism 1"] }

    before do
      render_inline(described_class.new(**args))
    end

    it "renders the course details" do
      expect(rendered_component).to have_text("#{course.name} (#{course.code})")
    end

    it "renders the level" do
      expect(rendered_component).to have_text(course.level.capitalize)
    end

    it "renders the age range" do
      expect(rendered_component).to have_text(age_range_for_summary_view(course.age_range))
    end

    it "renders the start date" do
      expect(rendered_component).to have_text(date_for_summary_view(course.start_date))
    end

    it "renders the duration" do
      expect(rendered_component).to have_text("#{course.duration_in_years} years")
    end

    it "renders study_mode" do
      expect(rendered_component).to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__key", text: "Full time or part time")
    end

    it "renders the selected study_mode" do
      expect(rendered_component).to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__value", text: "Full time")
    end

    if described_class == PublishCourseDetails::View
      it "renders 7 rows on the confirmation page" do
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 7)
      end
    else
      it "renders 8 rows on the confirmation page" do
        expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 8)
      end
    end

    context "non study mode training route" do
      let(:trainee) { build(:trainee, :assessment_only) }

      it "does not render study_mode" do
        expect(rendered_component).not_to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__key", text: "Full time or part time")
      end

      it "does not render the selected study_mode" do
        expect(rendered_component).not_to have_selector(".govuk-summary-list__row.full-time-or-part-time .govuk-summary-list__value", text: "Full time")
      end

      if described_class == PublishCourseDetails::View
        it "renders 6 rows on the confirmation page" do
          expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 6)
        end
      else
        it "renders 7 rows on the confirmation page" do
          expect(rendered_component).to have_selector(".govuk-summary-list__row", count: 7)
        end
      end
    end

    context "with itt_start_date set" do
      let(:itt_start_date) { Time.zone.now }

      it "renders the itt start date" do
        expect(rendered_component).to have_text(date_for_summary_view(course.start_date))
      end
    end
  end

  context "course subjects" do
    let(:course) { create(:course_with_subjects, subjects_count: subject_count) }

    before do
      render_inline(described_class.new(**args))
    end

    context "with one subject" do
      let(:specialisms) { ["Specialism 1"] }
      let(:subject_count) { 1 }
      let(:expected_names) { subjects_for_summary_view(specialisms.first, nil, nil) }

      it "renders the first subject's name" do
        expect(rendered_component).to have_text(expected_names)
      end

      it "displays the correct subject summary label" do
        expect(rendered_component).to have_text(I18n.t("publish_course_details.view.subject"))
      end
    end

    context "with two subjects" do
      let(:specialisms) { ["Specialism 1", "Specialism 2"] }
      let(:subject_count) { 2 }
      let(:expected_names) { subjects_for_summary_view(specialisms.first, specialisms.second, nil) }

      it "renders the first and second subject's name" do
        expect(rendered_component).to have_text(expected_names)
      end

      it "displays the correct subject summary label" do
        expect(rendered_component).to have_text(I18n.t("publish_course_details.view.multiple_subjects"))
      end
    end

    context "with three subjects" do
      let(:specialisms) { ["Specialism 1", "Specialism 2", "Specialism 3"] }
      let(:subject_count) { 3 }
      let(:expected_names) { subjects_for_summary_view(*specialisms) }

      it "renders the first, second and third subject's name" do
        expect(rendered_component).to have_text(expected_names)
      end
    end
  end
end

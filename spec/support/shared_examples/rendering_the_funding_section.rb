# frozen_string_literal: true

RSpec.shared_examples "rendering the funding section" do
  context "when a trainee is on a route with a bursary" do
    let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:trainee) { create(:trainee, :with_start_date, :with_study_mode_and_course_dates, :incomplete_draft, route) }

    before { create(:funding_method, :with_subjects, training_route: route) }

    context "and has not entered their course details" do
      it "renders the funding section as 'cannot start yet'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "cannot start yet"
      end
    end

    context "and has entered their course details" do
      before { trainee.progress.course_details = true }

      it "renders the funding section as 'incomplete'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "incomplete"
      end
    end
  end

  context "when a trainee is on a route with no bursary" do
    let(:trainee) { create(:trainee, :with_start_date, :incomplete_draft, TRAINING_ROUTE_ENUMS[:assessment_only]) }

    before { create(:funding_method, :with_subjects, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad]) }

    context "and has not entered their course details" do
      it "renders the funding section as 'cannot start yet'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "cannot start yet"
      end
    end

    context "and has entered their course details" do
      before { trainee.progress.course_details = true }

      it "renders the funding section as 'incomplete'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "incomplete"
      end
    end
  end
end

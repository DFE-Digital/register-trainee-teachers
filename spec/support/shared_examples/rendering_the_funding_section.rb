# frozen_string_literal: true

shared_examples "rendering the funding section" do
  context "when a trainee is on a route with a bursary" do
    let(:route) { ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name }
    let(:trainee) { create(:trainee, :with_start_date, :with_study_mode_and_course_dates, :incomplete_draft, route, start_academic_cycle: current_academic_cycle) }
    let!(:current_academic_cycle) { create(:academic_cycle, :current) }

    before { create(:funding_method, :with_subjects, training_route: route) }

    context "and has not entered their course details" do
      it "renders the funding section as 'cannot start yet'" do
        render_inline(described_class.new(trainee:))
        expect(rendered_content).to have_css "#funding-status", text: "Cannot start yet"
      end
    end

    context "and has entered their course details" do
      before { trainee.progress.course_details = true }

      it "renders the funding section as 'incomplete'" do
        render_inline(described_class.new(trainee:))
        expect(rendered_content).to have_css "#funding-status", text: "Incomplete"
      end
    end
  end

  context "when a trainee is on a route with no bursary" do
    let!(:current_academic_cycle) { create(:academic_cycle, :current) }
    let(:trainee) { create(:trainee, :with_start_date, :incomplete_draft, ReferenceData::TRAINING_ROUTES.assessment_only.name, start_academic_cycle: current_academic_cycle) }

    before { create(:funding_method, :with_subjects, training_route: ReferenceData::TRAINING_ROUTES.provider_led_postgrad.name) }

    context "and has not entered their course details" do
      it "renders the funding section as 'cannot start yet'" do
        render_inline(described_class.new(trainee:))
        expect(rendered_content).to have_css "#funding-status", text: "Cannot start yet"
      end
    end

    context "and has entered their course details" do
      before { trainee.progress.course_details = true }

      it "renders the funding section as 'incomplete'" do
        render_inline(described_class.new(trainee:))
        expect(rendered_content).to have_css "#funding-status", text: "Incomplete"
      end
    end
  end
end

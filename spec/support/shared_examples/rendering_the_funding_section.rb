# frozen_string_literal: true

RSpec.shared_examples "rendering the funding section" do
  context "when a trainee on a route with a bursary" do
    let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:trainee) { create(:trainee, :draft, route) }

    before { create(:bursary, :with_bursary_subjects, training_route: route) }

    context "and has not entered their course details" do
      it "renders the funding section as 'cannot start yet'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "cannot start yet"
      end
    end

    context "and has entered their course details" do
      before { trainee.course_subject_one = "subject" }

      it "renders the funding section as 'incomplete'" do
        render_inline(described_class.new(trainee: trainee))
        expect(rendered_component).to have_css "#funding-status", text: "incomplete"
      end
    end
  end

  context "when a trainee on a route with no bursary" do
    let(:trainee) { create(:trainee, :draft, TRAINING_ROUTE_ENUMS[:assessment_only]) }

    before { create(:bursary, :with_bursary_subjects, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad]) }

    it "renders the funding section as 'incomplete'" do
      render_inline(described_class.new(trainee: trainee))
      expect(rendered_component).to have_css "#funding-status", text: "incomplete"
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe "trainees/funding/funding_eligibilities/edit", feature_funding_eligibility_step: true do
  # The funding state is stubbed so the view can be exercised for every state
  # without seeding funding methods, academic cycles or allocation subjects.
  let!(:academic_cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:trainee) { create(:trainee, :provider_led_postgrad) }
  let(:can_apply_for_grant) { false }
  let(:offer_exception_subject) { false }
  let(:funding_manager) do
    instance_double(
      FundingManager,
      eligibility_content_key: content_key,
      no_funding?: no_funding,
      can_apply_for_grant?: can_apply_for_grant,
      allocation_subject_name: "Drama",
      offer_exception_subject?: offer_exception_subject,
      funding_guidance_url: "https://www.gov.uk/funding-guidance",
      using_draft_amounts?: false,
    )
  end

  before do
    # ApplicationController sets the GOV.UK form builder as the default; a bare
    # view spec has no such controller, so set it on the view explicitly.
    view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder
    # The breadcrumb back-link builds a route from the live request, which a bare
    # view spec doesn't provide; stub it so we can assert on the page body.
    allow(DynamicBackLink::View).to receive(:new).and_return(instance_double(DynamicBackLink::View, render_in: ""))
    assign(:trainee, trainee)
    assign(:funding_manager, funding_manager)
    assign(:funding_eligibility_form, Funding::EligibilityForm.new(trainee))
    render
  end

  context "when the trainee is on a bursary/scholarship route" do
    let(:content_key) { :bursary_scholarship }
    let(:no_funding) { false }

    it "asks the bursary/scholarship question with Yes/No options and guidance" do
      expect(rendered).to have_text("Has the trainee been approved for UK Student Finance?")
      expect(rendered).to have_text("This determines whether the trainee can be considered for a bursary or scholarship.")
      expect(rendered).to have_text("Bursaries and scholarships are available to trainees")
      expect(rendered).to have_link("Funding: initial teacher training (ITT), academic year 2026 to 2027 (opens in new tab)")
      expect(rendered).to have_field(type: "radio", count: 2)
    end

    context "when the subject is not a language or physics" do
      let(:offer_exception_subject) { false }

      it "shows the student finance sentence without the offer exception" do
        expect(rendered).to have_text("Trainees are only eligible for a bursary or scholarship if they qualify for student finance criteria.")
        expect(rendered).to have_link("qualify for student finance criteria", href: "https://www.gov.uk/student-finance/who-qualifies")
        expect(rendered).not_to have_text("unless they received an offer")
      end
    end

    context "when the subject is a language or physics" do
      let(:offer_exception_subject) { true }

      it "shows the student finance sentence with the offer exception" do
        expect(rendered).to have_text("unless they received an offer for a languages or physics course before 5pm on 7 May 2026")
      end
    end
  end

  context "when the trainee is on a grant route" do
    let(:content_key) { :grant }
    let(:no_funding) { false }

    it "asks the grant question" do
      expect(rendered).to have_text("Is the trainee eligible for grant funding?")
      expect(rendered).to have_text("We give grants to ITT providers")
      expect(rendered).to have_field(type: "radio", count: 2)
    end
  end

  context "when the trainee is on the early years postgrad route" do
    let(:content_key) { :training_bursary }
    let(:no_funding) { false }

    it "asks the training bursary and grant questions on the same screen" do
      expect(rendered).to have_text("Is the trainee eligible for a training bursary?")
      expect(rendered).to have_text("Should the provider be awarded a grant?")
      expect(rendered).to have_link("Early years initial teacher training: 2026 to 2027 funding guidance (opens in new tab)")
    end
  end

  context "when the trainee is on the early years salaried route" do
    let(:content_key) { :training_grant }
    let(:no_funding) { false }

    it "asks the training grant question" do
      expect(rendered).to have_text("Is the trainee eligible for a training grant?")
      expect(rendered).to have_text("Early years ITT (EYITT) providers will receive training grant funding")
    end
  end

  context "when the trainee is on a non-early-years route with no funding" do
    let(:content_key) { :no_funding }
    let(:no_funding) { true }

    it "shows the no-funding information, no question, and a way to continue" do
      expect(rendered).to have_text("There is no bursary, scholarship or grant funding available on the")
      expect(rendered).to have_text("route for the academic year 2026 to 2027")
      expect(rendered).to have_link("itt.funding@education.gov.uk", href: "mailto:itt.funding@education.gov.uk")
      expect(rendered).to have_link("Continue")
      expect(rendered).not_to have_field(type: "radio")
    end
  end

  context "when the trainee is on an early-years route with no funding" do
    let(:content_key) { :no_funding_early_years }
    let(:no_funding) { true }

    it "shows the early-years no-funding information and no question" do
      expect(rendered).to have_text("There is no training bursary or training grant available on the")
      expect(rendered).to have_link("Early years initial teacher training: 2026 to 2027 funding guidance (opens in new tab)")
      expect(rendered).not_to have_field(type: "radio")
    end
  end

  context "when the route is funded but the trainee's subject is not" do
    let(:content_key) { :no_funding_subject }
    let(:no_funding) { true }

    it "shows subject-specific no-funding information and no question" do
      expect(rendered).to have_text("available for Drama on the")
      expect(rendered).to have_text("route for the academic year 2026 to 2027")
      expect(rendered).to have_link("itt.funding@education.gov.uk", href: "mailto:itt.funding@education.gov.uk")
      expect(rendered).not_to have_field(type: "radio")
    end
  end
end

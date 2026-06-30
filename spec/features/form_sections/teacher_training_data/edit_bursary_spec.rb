# frozen_string_literal: true

require "rails_helper"

feature "edit bursary" do
  background { given_i_am_authenticated }

  let(:course_subject) { CourseSubjects::EARLY_YEARS_TEACHING }

  scenario "edit with valid parameters" do
    given_a_trainee_exists(:provider_led_postgrad, :with_valid_itt_start_date, :with_hesa_trainee_detail, course_subject_one: course_subject, funding_eligibility: :eligible)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    and_i_choose_applying_for_bursary

    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
    and_the_hesa_trainee_detail_funding_method_is_postgraduate_bursary
  end

  scenario "submitting with invalid parameters" do
    given_a_trainee_exists(:provider_led_postgrad, :with_valid_itt_start_date, course_subject_one: course_subject)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  context "early years postgrad training route" do
    background { given_there_is_grant_funding_available_for_early_years_postgrad }

    scenario "edit with valid parameters for tiered bursary" do
      given_an_early_years_postgrad_trainee_exists
      when_i_visit_the_bursary_page
      and_i_choose_the_applicable_funding_options

      and_i_submit_the_form
      then_i_am_redirected_to_the_funding_confirmation_page
      and_the_hesa_trainee_detail_funding_method_is_tier_one
    end

    scenario "the funding guidance link points to the early years guidance for the academic year" do
      given_an_early_years_postgrad_trainee_exists
      when_i_visit_the_bursary_page
      then_the_funding_guidance_link_points_to_the_early_years_guidance
    end
  end

  scenario "the funding guidance link points to the itt guidance for non early years routes" do
    given_a_trainee_exists(:provider_led_postgrad, :with_valid_itt_start_date, :with_hesa_trainee_detail, course_subject_one: course_subject, funding_eligibility: :eligible)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    then_the_funding_guidance_link_points_to_the_itt_guidance
  end

  scenario "redirects to confirmation when not eligible and subject is not in the fund code exception list" do
    given_a_not_eligible_trainee_exists
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    then_i_am_redirected_to_the_funding_confirmation_page
  end

  scenario "renders the bursary form when not eligible but subject is in the fund code exception list" do
    given_a_not_eligible_trainee_exists
    and_a_bursary_exists_for_an_exception_subject
    when_i_visit_the_bursary_page
    then_i_see_the_bursary_page
  end

private

  def given_an_early_years_postgrad_trainee_exists
    trainee = given_a_trainee_exists(:early_years_postgrad, :with_valid_itt_start_date, :with_hesa_trainee_detail, funding_eligibility: :eligible)
    trainee.set_early_years_course_details
    trainee.save
  end

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def and_i_choose_applying_for_bursary
    bursary_page.applying_for_bursary.click
  end

  def and_i_choose_the_applicable_funding_options
    page.choose("funding-grant-and-tiered-bursary-form-custom-applying-for-grant-yes-field")
    page.choose("funding-grant-and-tiered-bursary-form-custom-bursary-tier-tier-one-field")
  end

  def and_i_submit_the_form
    bursary_page.submit_button.click
  end

  def and_i_see_how_much_the_bursary_is_for
    expect(bursary_page).to have_text(
      "The course you have selected has a bursary available of £100,000 for astrology",
    )
  end

  def then_i_see_error_messages
    expect(bursary_page).to have_text(
      I18n.t("activemodel.errors.models.funding/bursary_form.attributes.applying_for_bursary.inclusion"),
    )
  end

  def and_a_bursary_exists_for_their_subject
    funding_method = create(:funding_method, training_route: :provider_led_postgrad, amount: 100_000)
    allocation_subject = create(:allocation_subject, name: "magic", funding_methods: [funding_method])
    create(:subject_specialism, allocation_subject: allocation_subject, name: course_subject)
  end

  def and_a_bursary_exists_for_an_exception_subject
    funding_method = create(:funding_method, training_route: :provider_led_postgrad, amount: 100_000)
    allocation_subject = create(:allocation_subject, name: AllocationSubjects::PHYSICS, funding_methods: [funding_method])
    create(:subject_specialism, allocation_subject: allocation_subject, name: course_subject)
    trainee.update!(course_allocation_subject: allocation_subject)
  end

  def given_a_not_eligible_trainee_exists
    given_a_trainee_exists(
      :provider_led_postgrad,
      :with_valid_itt_start_date,
      course_subject_one: course_subject,
      funding_eligibility: :not_eligible,
    )
  end

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end

  def then_i_see_the_bursary_page
    expect(bursary_page).to be_displayed(id: trainee.slug)
  end

  def then_the_funding_guidance_link_points_to_the_early_years_guidance
    academic_year = trainee.start_academic_cycle.label.parameterize
    expect(bursary_page).to have_link(
      "check the funding rules for this academic year",
      href: "https://www.gov.uk/guidance/early-years-initial-teacher-training-#{academic_year}-funding-guidance",
    )
  end

  def then_the_funding_guidance_link_points_to_the_itt_guidance
    academic_year = trainee.start_academic_cycle.label.parameterize
    expect(bursary_page).to have_link(
      "check the funding rules for this academic year",
      href: "https://www.gov.uk/government/publications/funding-initial-teacher-training-itt/funding-initial-teacher-training-itt-academic-year-#{academic_year}",
    )
  end

  def and_the_hesa_trainee_detail_funding_method_is_postgraduate_bursary
    expect(trainee.reload.hesa_trainee_detail.funding_method)
      .to eq(Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY)
  end

  def and_the_hesa_trainee_detail_funding_method_is_tier_one
    expect(trainee.reload.hesa_trainee_detail.funding_method)
      .to eq(Hesa::CodeSets::BursaryLevels::TIER_ONE)
  end
end

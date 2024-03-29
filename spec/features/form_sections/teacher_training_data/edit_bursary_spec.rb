# frozen_string_literal: true

require "rails_helper"

feature "edit bursary" do
  background { given_i_am_authenticated }

  let(:course_subject) { CourseSubjects::EARLY_YEARS_TEACHING }

  scenario "edit with valid parameters" do
    given_a_trainee_exists(:provider_led_postgrad, :with_valid_itt_start_date, course_subject_one: course_subject)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    and_i_choose_applying_for_bursary

    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
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
    end
  end

private

  def given_an_early_years_postgrad_trainee_exists
    trainee = given_a_trainee_exists(:early_years_postgrad, :with_valid_itt_start_date)
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

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end
end

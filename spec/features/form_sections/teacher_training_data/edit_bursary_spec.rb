# frozen_string_literal: true

require "rails_helper"

feature "edit bursary", type: :feature do
  background { given_i_am_authenticated }

  let(:course_subject) { CourseSubjects::LAW }

  scenario "edit with valid parameters" do
    given_a_trainee_exists(:provider_led_postgrad, course_subject_one: course_subject, itt_start_date: 1.day.ago)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    and_i_choose_applying_for_bursary

    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
  end

  scenario "submitting with invalid parameters" do
    given_a_trainee_exists(:provider_led_postgrad, course_subject_one: course_subject, itt_start_date: 1.day.ago)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

  scenario "edit with valid parameters for tiered bursary" do
    given_a_trainee_exists(:early_years_postgrad, itt_start_date: 1.day.ago)
    when_i_visit_the_bursary_page
    and_i_choose_the_applicable_bursary_tier

    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
  end

private

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def and_i_choose_applying_for_bursary
    bursary_page.applying_for_bursary.click
  end

  def and_i_choose_the_applicable_bursary_tier
    bursary_page.bursary_tier.click
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

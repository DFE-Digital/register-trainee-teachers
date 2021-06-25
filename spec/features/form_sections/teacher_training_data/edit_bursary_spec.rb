# frozen_string_literal: true

require "rails_helper"

feature "edit bursary", type: :feature do
  background { given_i_am_authenticated }

  let(:course_subject) { Dttp::CodeSets::CourseSubjects::LAW }

  before do
    given_a_trainee_exists(:provider_led_postgrad, course_subject_one: course_subject)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_bursary_page
  end

  scenario "edit with valid parameters" do
    and_i_update_the_bursary

    # TODO: uncomment this when the confrimation page is added
    # and_i_submit_the_form
    # then_i_am_redirected_to_the_funding_confirmation_page
  end

  scenario "submitting with invalid parameters" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

private

  def when_i_visit_the_bursary_page
    bursary_page.load(id: trainee.slug)
  end

  def and_i_update_the_bursary
    bursary_page.applying_for_bursary.click
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
    bursary = create(:bursary, training_route: :provider_led_postgrad, amount: 100_000)
    allocation_subject = create(:allocation_subject, name: "magic", bursaries: [bursary])
    create(:subject_specialism, allocation_subject: allocation_subject, name: course_subject)
  end
end

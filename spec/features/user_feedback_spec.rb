# frozen_string_literal: true

require "rails_helper"

feature "User Feedback" do
  scenario "A user provides feedback via the home page link" do
    given_i_am_authenticated
    when_i_click_on_the_feedback_link
    and_i_see_the_feedback_form
    and_i_click_on_cancel_link
    then_i_see_the_home_page

    when_i_click_on_the_feedback_link
    and_i_see_the_questions
    and_i_click_continue
    then_i_see_validation_errors

    when_i_select_the_option("Satisfied")
    and_i_fill_the_fields
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_click_on_cancel_link
    then_i_see_the_home_page

    when_i_click_on_the_feedback_link
    and_i_select_the_option("Satisfied")
    and_i_fill_the_fields
    and_i_click_continue
    and_i_see_the_check_your_answers_page

    when_i_click_change_satisfaction_level
    and_i_see_the_feedback_form
    and_i_select_the_option("Very dissatisfied")
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_updated_satisfaction_level

    when_i_click_change_improvement_suggestion
    and_i_see_the_feedback_form
    and_i_update_improvement_suggestion
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_updated_improvement_suggestion

    and_i_click_on_send_feedback
    then_i_the_thank_you_page
    feedback_confirmation_page.return_to_home_link.click
    then_i_see_the_home_page
  end

  scenario "A user provides feedback via the phase banner link" do
    when_i_visit_home
    and_i_click_on_the_phase_banner_feedback_link
    and_i_see_the_feedback_form
    and_i_select_the_option("Satisfied")
    and_i_fill_the_fields
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_click_on_send_feedback
    then_i_the_thank_you_page
  end

  scenario "A user provides feedback via the footer link" do
    when_i_visit_home
    and_i_click_on_the_footer_feedback_link
    and_i_see_the_feedback_form
    and_i_select_the_option("Dissatisfied")
    and_i_fill_the_fields
    and_i_click_continue
    then_i_see_the_check_your_answers_page
    and_i_click_on_send_feedback
    then_i_the_thank_you_page
  end

private

  def when_i_visit_home
    visit root_path
  end

  def and_i_click_on_the_phase_banner_feedback_link
    within(".govuk-phase-banner") do
      click_on "feedback"
    end
  end

  def and_i_click_on_the_footer_feedback_link
    within(".govuk-footer") do
      click_on "Give feedback to help us improve Register trainee teachers"
    end
  end

  def when_i_click_on_the_feedback_link
    within("#main-content") do
      click_on "Give feedback to help us improve Register trainee teachers"
    end
  end

  def and_i_click_on_cancel_link
    feedback_page.cancel_link.click
  end

  def then_i_see_the_home_page
    expect(page).to have_current_path(root_path)
  end

  def and_i_see_the_feedback_form
    expect(page).to have_content("Give feedback on Register trainee teachers")
  end

  def and_i_see_the_questions
    expect(page).to have_content("Overall, how do you feel about this service?")
    expect(page).to have_content("How could we improve this service?")
    expect(page).to have_content("Do not include any personal or sensitive information")
    expect(page).to have_content("You can enter up to 200 words")
    expect(page).to have_content("If you want a reply (optional)")
    expect(page).to have_content("If you would like us to contact you, please leave your details below.")
    expect(page).to have_content("Your name")
    expect(page).to have_content("Your email address")
  end

  def and_i_click_continue
    feedback_page.continue_button.click
  end

  def then_i_see_validation_errors
    expect(feedback_page).to have_error_summary
  end

  def when_i_select_the_option(option)
    choose option
  end

  alias_method :and_i_select_the_option, :when_i_select_the_option

  def and_i_fill_the_fields
    fill_in "How could we improve this service?", with: "More documentation would be helpful"
    fill_in "Your name", with: "Jane Smith"
    fill_in "Your email address", with: "user@example.com"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_content("Check your answers before sending your feedback")
  end

  alias_method :and_i_see_the_check_your_answers_page, :then_i_see_the_check_your_answers_page

  def when_i_click_change_satisfaction_level
    click_on "Change satisfaction level"
  end

  def when_i_click_change_improvement_suggestion
    click_on "Change improvement suggestion"
  end

  def and_i_update_improvement_suggestion
    fill_in "How could we improve this service?", with: "Better error messages please"
  end

  def and_i_see_the_updated_satisfaction_level
    expect(page).to have_content("Very dissatisfied")
  end

  def and_i_see_the_updated_improvement_suggestion
    expect(page).to have_content("Better error messages please")
  end

  def and_i_click_on_send_feedback
    feedback_check_page.send_feedback_button.click
  end

  def then_i_the_thank_you_page
    expect(page).to have_content("Thank you for submitting feedback")
    expect(page).to have_content("If you gave us your name and email, we will respond within 5 working days.")
  end
end

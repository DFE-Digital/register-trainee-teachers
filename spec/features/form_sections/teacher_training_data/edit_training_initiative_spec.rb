# frozen_string_literal: true

require "rails_helper"

feature "edit training initiative", type: :feature do
  background { given_i_am_authenticated }

  let(:course_subject) { CourseSubjects::LAW }

  scenario "edit with valid parameters with bursary" do
    given_a_trainee_exists(:provider_led_postgrad, course_subject_one: course_subject)
    and_a_bursary_exists_for_their_subject
    when_i_visit_the_training_initiative_page
    and_i_update_the_training_initiative
    and_i_submit_the_form
    then_i_am_redirected_to_the_bursary_page
  end

  scenario "edit with valid parameters without bursary" do
    given_a_trainee_exists(:assessment_only)
    when_i_visit_the_training_initiative_page
    and_i_update_the_training_initiative
    and_i_submit_the_form
    then_i_am_redirected_to_the_funding_confirmation_page
  end

  scenario "edit with valid parameters on the early_years_postgrad route" do
    given_a_trainee_exists(:early_years_postgrad)
    when_i_visit_the_training_initiative_page
    and_i_update_the_training_initiative
    and_i_submit_the_form
    then_i_am_redirected_to_the_bursary_page
  end

  scenario "submitting with invalid parameters" do
    given_a_trainee_exists
    when_i_visit_the_training_initiative_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

private

  def when_i_visit_the_training_initiative_page
    training_initiative_page.load(id: trainee.slug)
  end

  def and_i_update_the_training_initiative
    training_initiative_page.transition_to_teach.click
  end

  def and_i_submit_the_form
    training_initiative_page.submit_button.click
  end

  def then_i_see_error_messages
    expect(new_provider_page).to have_text(
      I18n.t("activemodel.errors.models.funding/training_initiatives_form.attributes.training_initiative.blank"),
    )
  end

  def then_i_am_redirected_to_the_bursary_page
    expect(bursary_page).to be_displayed(id: trainee.slug)
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

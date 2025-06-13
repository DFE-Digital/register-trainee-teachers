# frozen_string_literal: true

require "rails_helper"

feature "edit training initiative" do
  background { given_i_am_authenticated }

  let(:course_subject) { CourseSubjects::LAW }

  context "with valid parameters" do
    scenario "with bursary redirects to bursary page" do
      given_a_provider_led_postgrad_trainee_exists
      and_a_bursary_exists_for_their_subject
      when_i_visit_the_training_initiative_page
      and_i_update_the_training_initiative("international_relocation_payment")
      and_i_submit_the_form
      then_i_am_redirected_to_the_bursary_page
    end

    scenario "without bursary redirects to funding confirmation page" do
      given_a_trainee_exists(:assessment_only)
      when_i_visit_the_training_initiative_page
      and_i_update_the_training_initiative("international_relocation_payment")
      and_i_submit_the_form
      then_i_am_redirected_to_the_funding_confirmation_page
    end

    scenario "on the early_years_postgrad route redirects to bursary page" do
      given_a_trainee_exists(:early_years_postgrad, :with_valid_itt_start_date)
      when_i_visit_the_training_initiative_page
      and_i_update_the_training_initiative("international_relocation_payment")
      and_i_submit_the_form
      then_i_am_redirected_to_the_bursary_page
    end
  end

  # Single test to verify initiative selection in the UI
  # (We don't need to test every initiative - that's covered in funding_helper_spec.rb)
  scenario "can select an initiative and save it to the trainee record" do
    given_a_trainee_exists(:provider_led_postgrad)
    when_i_visit_the_training_initiative_page
    and_i_update_the_training_initiative("international_relocation_payment")
    and_i_submit_the_form
    then_the_trainee_has_the_correct_initiative("international_relocation_payment")
  end

  scenario "submitting with invalid parameters shows error messages" do
    given_a_trainee_exists
    when_i_visit_the_training_initiative_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

private

  def given_a_provider_led_postgrad_trainee_exists
    given_a_trainee_exists(:provider_led_postgrad,
                           :with_start_date,
                           :with_study_mode_and_course_dates,
                           :with_course_allocation_subject,
                           course_subject_one: course_subject)
  end

  def when_i_visit_the_training_initiative_page
    training_initiative_page.load(id: trainee.slug)
  end

  def and_i_update_the_training_initiative(initiative = "international_relocation_payment")
    radio_button = training_initiative_page.find("input[value='#{initiative}']", visible: :all)
    radio_button.click if radio_button.present?
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
    trainee.update(course_allocation_subject: allocation_subject)
  end

  def then_i_am_redirected_to_the_funding_confirmation_page
    expect(confirm_funding_page).to be_displayed(id: trainee.slug)
  end

  def then_the_trainee_has_the_correct_initiative(initiative)
    trainee.reload
    expect(trainee.training_initiative).to eq(initiative)
  end
end

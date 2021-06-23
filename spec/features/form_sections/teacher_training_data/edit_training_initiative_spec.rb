# frozen_string_literal: true

require "rails_helper"

feature "edit training initiative", type: :feature do
  background { given_i_am_authenticated }

  before do
    given_a_trainee_exists
    when_i_visit_the_training_initiative_page
  end

  scenario "edit with valid parameters" do
    and_i_update_the_training_initiative
    and_i_submit_the_form
    then_i_am_redirected_to_the_trainee_page
  end

  scenario "submitting with invalid parameters" do
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

  def then_i_am_redirected_to_the_trainee_page
    expect(review_draft_page).to be_displayed
  end

  def then_i_see_error_messages
    expect(new_provider_page).to have_text(
      I18n.t("activemodel.errors.models.funding/training_initiatives_form.attributes.training_initiative.blank"),
    )
  end
end

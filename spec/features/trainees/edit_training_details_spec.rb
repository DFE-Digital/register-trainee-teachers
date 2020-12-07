# frozen_string_literal: true

require "rails_helper"

feature "edit training details" do
  let(:new_trainee_id) { trainee.trainee_id + "new" }

  background { given_i_am_authenticated }

  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_training_details_page
    and_i_update_the_training_details
    then_i_am_redirected_to_the_summary_page
    and_the_training_details_are_updated
  end

  def when_i_visit_the_training_details_page
    @training_details_page ||= PageObjects::Trainees::TrainingDetails.new
    @training_details_page.load(id: trainee.id)
  end

  def and_i_update_the_training_details
    @training_details_page.trainee_id.set(new_trainee_id)
    @training_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    expect(summary_page).to be_displayed(id: trainee.id)
  end

  def and_the_training_details_are_updated
    when_i_visit_the_training_details_page
    expect(@training_details_page.trainee_id.value).to eq(new_trainee_id)
  end
end

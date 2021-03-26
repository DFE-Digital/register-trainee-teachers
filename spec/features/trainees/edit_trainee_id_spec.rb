# frozen_string_literal: true

require "rails_helper"

feature "edit Trainee ID" do
  let(:new_trainee_id) { trainee.trainee_id + "new" }

  background do
    given_i_am_authenticated
    given_a_trainee_exists(:submitted_for_trn)
    given_i_visited_the_record_page
    when_i_visit_the_edit_trainee_id_page
    when_i_change_the_trainee_id
    when_i_click_continue
  end

  scenario "updates the Trainee ID" do
    then_i_am_taken_to_the_confirmation_page
    when_i_confirm
    then_i_am_redirected_to_the_record_page
    then_the_trainee_id_is_updated
  end

  def when_i_visit_the_edit_trainee_id_page
    trainee_id_edit_page.load(trainee_id: trainee.slug)
  end

  def when_i_change_the_trainee_id
    trainee_id_edit_page.trainee_id_input.set(new_trainee_id)
  end

  def when_i_click_continue
    trainee_id_edit_page.continue.click
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(confirm_trainee_id_page).to be_displayed(id: trainee.slug)
  end

  def when_i_confirm
    expect(confirm_details_page).to be_displayed(id: trainee.slug, section: "trainee-id")
    confirm_details_page.update_record_button.click
  end

  def then_the_trainee_id_is_updated
    expect(record_page.record_detail.trainee_id_row).to have_text(new_trainee_id)
  end
end

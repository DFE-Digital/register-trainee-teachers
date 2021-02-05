# frozen_string_literal: true

require "rails_helper"

feature "edit Trainee ID" do
  let(:new_trainee_id) { trainee.trainee_id + "new" }

  background do
    given_i_am_authenticated
    given_a_trainee_exists(:submitted_for_trn)
    when_i_visit_the_edit_trainee_id_page
    when_i_change_the_trainee_id
    when_i_click_continue
  end

  scenario "updates the Trainee ID" do
    then_i_am_taken_to_the_confirmation_page
    when_i_confirm
    then_i_am_redirected_to_the_trainee_edit_page
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
    expect(page.current_path).to eq("/trainees/#{trainee.slug}/trainee-id/confirm")
  end

  def when_i_confirm
    confirm_page = PageObjects::Trainees::ConfirmTraineeId.new
    confirm_page.confirm.click
  end

  def then_i_am_redirected_to_the_trainee_edit_page
    expect(page.current_path).to eq("/trainees/#{trainee.slug}")
  end

  def then_the_trainee_id_is_updated
    when_i_visit_the_edit_trainee_id_page
    expect(trainee_id_edit_page.trainee_id_input.value).to eq(new_trainee_id)
  end

  def confirm_trainee_id_page
    @confirm_page ||= PageObjects::Trainees::ConfirmTraineeId.new
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "Deleting a trainee" do
  let(:system_admin) { create(:user, system_admin: true) }

  before do
    given_i_am_authenticated(user: system_admin)
  end

  scenario "can be done by an admin" do
    given_a_trainee_exists(:trn_received)
    and_i_am_on_the_trainee_record_page
    and_i_click_on_the_admin_tab
    and_i_click_delete_this_trainee
    when_i_select_a_delete_reason_and_continue
    then_i_should_be_on_the_confirmation_page
    when_i_confirm_delete
    then_i_should_be_on_trainees_index_page
    and_the_trainee_should_be_soft_deleted
  end

private

  def and_i_click_on_the_admin_tab
    record_page.admin_tab.click
  end

  def and_i_click_delete_this_trainee
    trainee_admin_page.delete.click
  end

  def when_i_select_a_delete_reason_and_continue
    admin_delete_trainee_reasons_page.delete_reasons.first.choose
    admin_delete_trainee_reasons_page.continue.click
  end

  def then_i_should_be_on_the_confirmation_page
    expect(admin_delete_trainee_confirmation_page).to be_displayed(id: trainee.slug)
  end

  def when_i_confirm_delete
    admin_delete_trainee_confirmation_page.confirm.click
  end

  def then_i_should_be_on_trainees_index_page
    expect(trainee_index_page).to be_displayed
  end

  def and_the_trainee_should_be_soft_deleted
    expect(trainee.reload.discarded_at).not_to be_nil
  end
end

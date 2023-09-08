# frozen_string_literal: true

require "rails_helper"

feature "pending TRNs" do
  let(:user) { create(:user, system_admin: true) }
  let(:trainee) { create(:trainee, :submitted_for_trn, :with_dqt_trn_request, first_names: "James Blint") }
  let(:trn_request) { trainee.dqt_trn_request }

  before do
    given_i_am_authenticated(user:)
    and_i_have_a_trainee_with_a_pending_trn
    when_i_visit_the_pending_trns_page
  end

  scenario "shows pending TRNs page" do
    then_i_see_the_pending_trns_page
    and_i_see_the_trainee
  end

  scenario "can check for TRN" do
    then_i_see_the_pending_trns_page
    when_i_click_check_for_trn
    then_i_see_the_pending_trns_page
  end

  scenario "can resubmit for TRN" do
    then_i_see_the_pending_trns_page
    when_i_click_resubmit_for_trn
    then_i_see_the_pending_trns_page
  end

  def and_i_have_a_trainee_with_a_pending_trn
    allow(Dqt::RegisterForTrnJob).to receive(:perform_now).and_return(
      OpenStruct.new(
        failed?: false,
      ),
    )
    trainee
  end

  def when_i_visit_the_pending_trns_page
    admin_pending_trns_page.load
  end

  def then_i_see_the_pending_trns_page
    expect(admin_pending_trns_page).to have_text("Trainees Pending TRN")
  end

  def and_i_see_the_trainee
    expect(admin_pending_trns_page).to have_text(trainee.first_names)
    expect(admin_pending_trns_page).to have_text(trainee.last_name)
  end

  def when_i_click_check_for_trn
    expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request:)
    admin_pending_trns_page.check_for_trn_button.click
  end

  def when_i_click_resubmit_for_trn
    expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee)
    admin_pending_trns_page.resumbit_for_trn_button.click
  end
end

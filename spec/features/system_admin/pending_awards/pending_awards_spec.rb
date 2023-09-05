# frozen_string_literal: true

require "rails_helper"

feature "pending awards" do
  attr_reader :trainee

  before do
    given_i_am_authenticated
    and_i_have_a_trainee_with_a_pending_award
    when_i_visit_the_pending_awards_page
  end

  scenario "shows pending awards page" do
    then_i_see_the_pending_awards_page
    and_i_see_the_trainee
  end

  scenario "can check for award" do
    # then_i_see_the_pending_awards_page
    # when_i_click_check_for_award
    # then_i_see_the_pending_awards_page
  end

  scenario "can resubmit for award" do
    # then_i_see_the_pending_trns_page
    # when_i_click_resubmit_for_trn
    # then_i_see_the_pending_trns_page
  end

  def and_i_have_a_trainee_with_a_pending_award
    @trainee = create(:trainee, :recommended_for_award)
  end

  def when_i_visit_the_pending_awards_page
    visit "/system-admin/pending_awards"
  end

  def then_i_see_the_pending_awards_page
    expect(page).to have_text("Trainees Pending Award")
  end

  def and_i_see_the_trainee
    expect(page).to have_text(trainee.first_names)
    expect(page).to have_text(trainee.last_name)
  end

  # def when_i_click_check_for_trn
  #   expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request:)
  #   admin_pending_trns_page.check_for_trn_button.click
  # end

  # def when_i_click_resubmit_for_trn
  #   expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee)
  #   admin_pending_trns_page.resumbit_for_trn_button.click
  # end
end

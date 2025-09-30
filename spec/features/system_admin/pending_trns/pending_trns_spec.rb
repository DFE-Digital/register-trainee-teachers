# frozen_string_literal: true

require "rails_helper"

feature "pending TRNs" do
  let(:trainee) { create(:trainee, :submitted_for_trn, :with_trs_trn_request, first_names: "James Blint") }
  let(:trn_request) { trainee.trs_trn_request }

  context "when I am authenticated as a system admin" do
    before do
      given_i_am_authenticated_as_system_admin
      and_i_have_a_trainee_with_a_pending_trn
      when_i_visit_the_pending_trns_page
    end

    scenario "shows pending TRNs page" do
      then_i_see_the_pending_trns_page
      and_i_see_the_trainee
      and_i_see_the_trn_request_details
    end

    scenario "can check for TRN", feature_integrate_with_dqt: true do
      then_i_see_the_pending_trns_page
      when_i_click_check_for_trn
      then_i_see_the_pending_trns_page
    end

    scenario "can resubmit for TRN", feature_integrate_with_dqt: true do
      then_i_see_the_pending_trns_page
      when_i_click_resubmit_for_trn
      then_i_see_the_pending_trns_page
    end

    context "with trainee in state submitted_for_trn with no TRN request" do
      let(:trainee) { create(:trainee, :submitted_for_trn, first_names: "James Blint") }

      it "shows a warning message" do
        then_i_see_the_pending_trns_page
        and_i_see_the_trainee
        when_i_click_check_for_trn_without_an_existing_request
      end

      it "creates a trn request", feature_integrate_with_dqt: true do
        then_i_see_the_pending_trns_page
        and_i_see_the_trainee
        when_i_click_resubmit_for_trn_without_an_existing_request
      end
    end
  end

  context "when I am authenticated as a regular user (not a system admin)" do
    before do
      given_i_am_authenticated
      and_i_have_a_trainee_with_a_pending_trn
    end

    scenario "the pending awards page is inaccessible" do
      expect { when_i_visit_the_pending_trns_page }.to raise_error(ActionController::RoutingError)
    end
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

  def and_i_see_the_trn_request_details
    expect(admin_pending_trns_page).to have_text(JSON.pretty_generate(trn_request.response))
  end

  def when_i_click_check_for_trn
    expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request:)
    admin_pending_trns_page.check_for_trn_button.click
  end

  def when_i_click_resubmit_for_trn
    expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee)
    admin_pending_trns_page.resumbit_for_trn_button.click
  end

  def when_i_click_check_for_trn_without_an_existing_request
    admin_pending_trns_page.check_for_trn_button.click
    expect(admin_pending_trns_page).to have_text("#{trainee.full_name} has no TRN request (it may have been manually deleted).")
  end

  def when_i_click_resubmit_for_trn_without_an_existing_request
    expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee)
    admin_pending_trns_page.resumbit_for_trn_button.click
  end
end

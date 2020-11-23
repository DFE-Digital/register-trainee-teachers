# frozen_string_literal: true

require "rails_helper"

feature "submit for TRN" do
  background { given_i_am_authenticated }

  before do
    stub_microsoft_oauth_success
    stub_request(:post, "#{Settings.dttp.api_base_url}/contacts").to_return(
      body: "",
      headers: {
        "OData-Version" => "4.0",
        "OData-EntityId" => "https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1/contacts(60f77a42-5f0e-e611-80e0-00155da84c03)",
      },
    )
  end

  describe "submission" do
    scenario "with all sections completed" do
      given_a_trainee_exists
      when_i_am_viewing_the_summary_page
      and_i_want_to_review_record_before_submitting_for_trn
      then_i_review_the_trainee_data
      and_i_click_the_submit_for_trn_button
      and_i_am_redirected_to_the_success_page
    end
  end

  describe "navigation" do
    context "clicking back to draft record" do
      scenario "returns the user to the summary page" do
        given_a_trainee_exists
        and_i_am_on_the_check_details_page
        when_i_click_back_to_draft_record
        then_i_am_redirected_to_the_summary_page
      end
    end

    context "clicking return to draft record later" do
      scenario "returns the user to the trainee records page" do
        given_a_trainee_exists
        and_i_am_on_the_check_details_page
        when_i_click_return_to_draft_later
        then_i_am_redirected_to_the_trainee_records_page
      end
    end
  end

  def when_i_am_viewing_the_summary_page
    summary_page.load(id: trainee.id)
  end

  def and_i_want_to_review_record_before_submitting_for_trn
    summary_page.review_this_record_link.click
  end

  def then_i_review_the_trainee_data
    expect(check_details_page).to be_displayed(id: trainee.id)
  end

  def and_i_click_the_submit_for_trn_button
    check_details_page.submit_button.click
  end

  def and_i_am_redirected_to_the_success_page
    expect(trn_success_page).to be_displayed(trainee_id: trainee.id)
  end

  def check_details_page
    @check_details_page ||= PageObjects::Trainees::CheckDetails::Show.new
  end

  def and_i_am_on_the_check_details_page
    check_details_page.load(id: trainee.id)
  end

  def trn_success_page
    @trn_success_page ||= PageObjects::Trainees::TrnSuccess.new
  end

  def when_i_click_back_to_draft_record
    check_details_page.back_to_draft_record.click
  end

  def when_i_click_return_to_draft_later
    check_details_page.return_to_draft_later.click
  end

  def then_i_am_redirected_to_the_trainee_records_page
    expect(trainee_index_page).to be_displayed
  end

  def stub_microsoft_oauth_success
    stub_request(
      :post,
      "https://login.microsoftonline.com/#{Settings.dttp.tenant_id}/oauth2/v2.0/token",
    ).to_return(
      body: {
        access_token: "token",
        expires_in: 3600,
      }.to_json,
    )
  end
end

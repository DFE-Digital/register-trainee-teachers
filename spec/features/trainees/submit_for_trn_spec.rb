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

  scenario "with a valid trainee" do
    given_a_valid_trainee_exists
    when_i_am_viewing_the_summary_page
    and_i_click_the_submit_for_trn_button
    then_i_am_redirected_to_the_success_page
  end

  def given_a_valid_trainee_exists
    trainee
  end

  def when_i_am_viewing_the_summary_page
    summary_page.load(id: trainee.id)
  end

  def and_i_click_the_submit_for_trn_button
    summary_page.submit_for_trn_button.click
  end

  def then_i_am_redirected_to_the_success_page
    expect(trn_success_page).to be_displayed(id: trainee.id)
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trn_success_page
    @trn_success_page ||= PageObjects::Trainees::TrnSuccess.new
  end

  def trainee
    @trainee ||= create(:trainee, provider: current_user.provider)
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

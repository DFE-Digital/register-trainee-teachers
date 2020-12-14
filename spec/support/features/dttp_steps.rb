# frozen_string_literal: true

module Features
  module DttpSteps
    def stub_dttp_placement_assignment_request(outcome_date:, status: 200)
      stub_microsoft_oauth_success

      url = "#{Dttp::Client.base_uri}/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})"
      body = { dfe_datestandardsassessmentpassed: outcome_date.in_time_zone.iso8601 }.to_json
      stub_request(:patch, url).with(body: body).to_return(status: status)
    end

    def stub_dttp_batch_request
      stub_microsoft_oauth_success

      stub_request(:post, "#{Dttp::Client.base_uri}/$batch").to_return(body: "/contacts#{SecureRandom.uuid}")
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
end

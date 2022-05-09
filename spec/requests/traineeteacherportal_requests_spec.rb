# frozen_string_literal: true

require "rails_helper"

RSpec.describe "requests to traineeteacherportal-test.education.gov.uk" do
  it "redirects / to register" do
    get "https://traineeteacherportal-test.education.gov.uk"

    expect(response).to redirect_to("#{Settings.base_url}/dttp-replaced")
  end

  it "redirects other paths typically used by portal to register" do
    get "https://traineeteacherportal-test.education.gov.uk/default.aspx#!/app/partials/dfeAppHome&id=0C1A66E4-0B9A-4C83-A0CB-4F902E76496E"

    expect(response).to redirect_to("#{Settings.base_url}/dttp-replaced")
  end
end

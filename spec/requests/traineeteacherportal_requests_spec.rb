# frozen_string_literal: true

require "rails_helper"

RSpec.describe "requests to traineeteacherportal-test.education.gov.uk" do
  it "redirects / to register" do
    get "/", headers: { host: "traineeteacherportal-test.education.gov.uk"}

    expect(response).to redirect_to("https://www.register-trainee-teachers.education.gov.uk/start_traineeteacherportal")
  end

  it "redirects other paths typically used by portal to register" do
    # Example URL:
    #
    # https://traineeteacherportal.education.gov.uk/default.aspx#!/app/partials/dfeAppHome&id=0C1A66E4-0B9A-4C83-A0CB-4F902E76496E
    get "/default.aspx#!/app/partials/dfeAppHome&id=0C1A66E4-0B9A-4C83-A0CB-4F902E76496E", headers: { host: "traineeteacherportal-test.education.gov.uk"}

    expect(response).to redirect_to("https://www.register-trainee-teachers.education.gov.uk/start_traineeteacherportal")
  end
end

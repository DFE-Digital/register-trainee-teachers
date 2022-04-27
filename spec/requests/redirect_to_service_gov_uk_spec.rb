# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET register-trainee-teachers.education.gov.uk", type: :request do
  it "redirects to register-trainee-teachers.service.gov.uk" do
    get "https://www.register-trainee-teachers.education.gov.uk/"
    expect(response.location).to eq("https://www.register-trainee-teachers.service.gov.uk/")
  end

  context "old portal requests" do
    it "does not redirect" do
      get "https://traineeteacher-portal.education.gov.uk/"
      expect(response).to have_http_status(:success)
    end
  end
end

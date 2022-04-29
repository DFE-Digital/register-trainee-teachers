# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET register-trainee-teachers.education.gov.uk", type: :request do
  it "redirects root to register-trainee-teachers.service.gov.uk" do
    get "https://www.register-trainee-teachers.education.gov.uk/"
    expect(response.location).to eq(Settings.base_url)
  end

  it "redirects paths to register-trainee-teachers.service.gov.uk" do
    get "https://www.register-trainee-teachers.education.gov.uk/accessibility"
    expect(response.location).to eq("#{Settings.base_url}/accessibility")
  end
end

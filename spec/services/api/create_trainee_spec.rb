# frozen_string_literal: true

require "rails_helper"

describe Api::CreateTrainee do
  it "works" do
    current_provider = create(:provider)
    trainee_attributes = { first_names: "Bob", last_name: "Roberts" }
    version = Settings.api.current_version

    result = described_class.call(
      current_provider:,
      trainee_attributes:,
      version:,
    )

    expect(result).to be_success
    expect(result.data).to be_a(Trainee)
    expect(result.data.first_names).to eq("John")
    expect(result.data.last_name).to eq("Doe")
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Api::FindDuplicateTrainees do
  it "returns trainees that are an exact match"
  it "does not return trainees for a different provider"
  it "does not return trainees with a different date of birth"

  it "does not return trainees with a different last name" do
    trainee = create(:trainee, last_name: "Smith")
    attributes = Api::TraineeAttributes.new(
      date_of_birth: trainee.date_of_birth,
      last_name: "Jones",
    )

    expect(described_class.call(provider: trainee.provider, attributes: attributes)).to be_empty
  end
end

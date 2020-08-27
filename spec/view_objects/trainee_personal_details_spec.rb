require "rails_helper"

RSpec.describe TraineePersonalDetails do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  it "only returns relevant fields" do
    expect(subject.call.keys).to eql([
      "Trainee ID",
      "First names",
      "Last name",
      "Gender",
      "Date of birth",
      "Nationality",
      "Ethnicity",
      "Disability",
    ])
  end
end

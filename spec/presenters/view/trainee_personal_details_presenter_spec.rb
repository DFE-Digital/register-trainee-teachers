require "rails_helper"

module View
  RSpec.describe TraineePersonalDetailsPresenter do
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
end

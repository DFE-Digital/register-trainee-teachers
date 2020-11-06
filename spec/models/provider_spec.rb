require "rails_helper"

describe Provider do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:name)
    end
  end
end

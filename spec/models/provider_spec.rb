# frozen_string_literal: true

require "rails_helper"

describe Provider do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:name)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users) }
  end
end

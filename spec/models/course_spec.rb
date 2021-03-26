# frozen_string_literal: true

require "rails_helper"

describe Course do
  context "fields" do
    subject { create(:course) }

    it "validates presence" do
      expect(subject).to validate_presence_of(:code)
      expect(subject).to validate_presence_of(:name)
    end

    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:provider_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:subjects) }
  end
end

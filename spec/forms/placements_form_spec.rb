# frozen_string_literal: true

require "rails_helper"

describe PlacementsForm, type: :model do
  let(:user) { create(:user) }
  let(:trainee) { create(:trainee) }

  subject { described_class.new(trainee, user:) }

  describe "track_validation_errors: false" do
    before do
      allow(Settings).to receive(:track_validation_errors).and_return(false)
    end

    it "saves validation errors" do
      subject.valid?
      expect(ValidationError.count).to be(0)

      subject.valid?
      expect(ValidationError.count).to be(0)
    end
  end
end

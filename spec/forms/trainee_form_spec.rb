# frozen_string_literal: true

require "rails_helper"

class TestForm < TraineeForm
  attr_accessor :test1, :test2, :test3
  validates_presence_of :test1, :test2, :test3

private

  def compute_fields
    {}
  end
end

describe TraineeForm, type: :model do
  let(:user) { create(:user) }
  let(:trainee) { create(:trainee) }
  subject { TestForm.new(trainee, user: user) }

  describe "track_validation_errors: true" do
    before do
      allow(Settings).to receive(:track_validation_errors).and_return(true)
    end

    it "saves validation errors" do
      subject.valid?
      expect(ValidationError.last.form_object).to eql("TestForm")
      expect(ValidationError.count).to be(1)

      subject.valid?
      expect(ValidationError.count).to be(2)
    end
  end

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

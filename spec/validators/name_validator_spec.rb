# frozen_string_literal: true

require "rails_helper"
class TestSubject
  include ActiveModel::Model

  attr_accessor :name

  validates :name, name: true
end

describe NameValidator do
  subject { TestSubject.new(name: name) }

  describe "#validates_each" do
    context "valid details" do
      let(:name) { "Fred" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "invalid details" do
      let(:name) { "21" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.keys).to include(:name)
      end
    end
  end
end

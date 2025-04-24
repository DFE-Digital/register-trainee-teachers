# frozen_string_literal: true

require "rails_helper"

describe EmailFormatValidator do
  let(:trainee) { build(:trainee) }

  subject { ContactDetailsForm.new(trainee) }

  before { subject.email = email }

  context "with a valid email" do
    let(:email) { "valid@example.com" }

    it "does not add an error" do
      expect(subject).to be_valid
    end
  end

  context "with an invalid email" do
    error_test = "error test"

    shared_examples_for error_test do
      it "adds an error" do
        expect(subject).not_to be_valid
        expect(subject.errors[:email]).not_to be_blank
      end
    end

    context "that is only @" do
      let(:email) { "@" }

      it_behaves_like error_test
    end

    context "that doesn't contain @" do
      let(:email) { "invalid" }

      it_behaves_like error_test
    end

    context "that doesn't match the email regex" do
      let(:email) { "invalid@b" }

      it_behaves_like error_test
    end

    context "that is too long" do
      let(:email) { "#{SecureRandom.alphanumeric(321)}@example.com" }

      it_behaves_like error_test
    end

    context "that has two consecutive periods" do
      let(:email) { "invalid..@example.com" }

      it_behaves_like error_test
    end

    context "that has a hostname that is too long" do
      valid_part = SecureRandom.alphanumeric(63)
      let(:email) { "invalid@#{Array.new(4, valid_part).join('.')}.com" }

      it_behaves_like error_test
    end

    context "that has a hostname with fewer than two parts" do
      let(:email) { "invalid@example" }

      it_behaves_like error_test
    end

    context "that has a hostname with a part that is too long" do
      let(:email) { "invalid@#{SecureRandom.alphanumeric(64)}.com" }

      it_behaves_like error_test
    end

    context "that has a hostname with a part that doesn't match the regex" do
      let(:email) { "invalid@example.#.com" }

      it_behaves_like error_test
    end

    context "that has a hostname with a final part that doesn't match the TLD regex" do
      let(:email) { "invalid@example.a" }

      it_behaves_like error_test
    end
  end
end

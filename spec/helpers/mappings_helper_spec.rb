# frozen_string_literal: true

require "rails_helper"

describe MappingsHelper do
  include MappingsHelper

  describe "#same_hesa_code?" do
    it "returns true if the two codes are the same" do
      expect(same_hesa_code?("05", "0005")).to be_truthy
    end

    it "returns false if the two codes are not the same" do
      expect(same_hesa_code?("06", "0005")).to be_falsey
    end

    it "returns false if only one code is given" do
      expect(same_hesa_code?(nil, "0005")).to be_falsey
    end
  end

  describe "#same_string?" do
    it "returns true if the two strings are the same" do
      expect(same_string?("'heLLo", "He`lLo")).to be_truthy
    end

    it "returns false if the two strings are not the same" do
      expect(same_string?("'heLp", "He`lLo")).to be_falsey
    end
  end

  describe "#sanitised_word" do
    it "removes any non word character" do
      expect(sanitised_word("'heL`Lo")).to eq("hello")
    end
  end

  describe "#sanitised_hesa" do
    it "returns the integer value for a hesa code" do
      expect(sanitised_hesa("004")).to eq(4)
    end

    it "returns nil if no code is given" do
      expect(sanitised_hesa("")).to be_nil
    end
  end
end

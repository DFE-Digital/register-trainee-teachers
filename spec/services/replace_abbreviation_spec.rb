# frozen_string_literal: true

require "rails_helper"

describe ReplaceAbbreviation do
  context "phrase has no abbreviated words" do
    let(:string) { "hello world" }

    it "returns nil" do
      expect(described_class.call(string: string)).to eq(string)
    end
  end

  context "various abbreviations for 'Church of England'" do
    it "returns 'Church of England'" do
      ["coe school", "CofE school", "C of E school"].each do |string|
        expect(described_class.call(string: string)).to eq("Church of England school")
      end
    end
  end
end

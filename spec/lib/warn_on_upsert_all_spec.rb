# frozen_string_literal: true

require "rails_helper"

RSpec.describe WarnOnUpsertAll do
  let(:logger) { instance_double(Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(Nationality).to receive(:upsert_all).and_call_original
  end

  context "when not in seeding mode" do
    it "logs a warning message" do
      expect(logger).to receive(:warn).with(match(/WARNING/))
      Nationality.upsert_all([{ name: "British" }], unique_by: :name)
    end
  end

  context "when in seeding mode" do
    before do
      allow(File).to receive(:basename).with($PROGRAM_NAME).and_return("rake")
      allow(ARGV).to receive(:include?).with("db:seed").and_return(true)
    end

    it "does not log a warning message" do
      expect(logger).not_to receive(:warn)
      Nationality.upsert_all([{ name: "British" }], unique_by: :name)
    end
  end
end

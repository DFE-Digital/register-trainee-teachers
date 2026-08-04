# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fauapi::PublishCatalogueJob do
  before do
    allow(Fauapi::PublishCatalogue).to receive(:call)
  end

  context "when fauapi is disabled" do
    before do
      allow(Settings.fauapi).to receive(:enabled).and_return(false)
    end

    it "does not publish" do
      described_class.perform_now

      expect(Fauapi::PublishCatalogue).not_to have_received(:call)
    end
  end

  context "when fauapi is enabled" do
    before do
      allow(Settings.fauapi).to receive(:enabled).and_return(true)
    end

    it "publishes the catalogue" do
      described_class.perform_now

      expect(Fauapi::PublishCatalogue).to have_received(:call)
    end
  end
end

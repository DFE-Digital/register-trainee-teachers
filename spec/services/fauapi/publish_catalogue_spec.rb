# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fauapi::PublishCatalogue do
  let(:manifests) do
    [
      { majorVersion: "v2025", name: Settings.fauapi.api_name },
      { majorVersion: "v2026", name: Settings.fauapi.api_name },
    ]
  end

  before do
    allow(Fauapi::BuildManifests).to receive(:call).and_return(manifests)
    allow(Fauapi::Client).to receive(:import)
    allow(Fauapi::Client).to receive(:publish)
  end

  context "when each major has exactly one catalogue entry" do
    before do
      allow(Fauapi::Client).to receive(:list_apis).and_return(
        [
          { "id" => 69, "name" => Settings.fauapi.api_name, "majorVersion" => "v2025" },
          { "id" => 70, "name" => Settings.fauapi.api_name, "majorVersion" => "v2026" },
        ],
      )
    end

    it "imports and publishes each major" do
      described_class.call

      expect(Fauapi::Client).to have_received(:import).with(manifests[0])
      expect(Fauapi::Client).to have_received(:import).with(manifests[1])
      expect(Fauapi::Client).to have_received(:publish).with(69)
      expect(Fauapi::Client).to have_received(:publish).with(70)
    end
  end

  context "when no matching entry exists after import" do
    before do
      allow(Fauapi::Client).to receive(:list_apis).and_return([])
    end

    it "raises" do
      expect { described_class.call }.to raise_error(Fauapi::PublishCatalogue::Error, /No catalogue entry/)
    end
  end

  context "when multiple entries match the same major" do
    before do
      allow(Fauapi::Client).to receive(:list_apis).and_return(
        [
          { "id" => 69, "name" => Settings.fauapi.api_name, "majorVersion" => "v2025" },
          { "id" => 99, "name" => Settings.fauapi.api_name, "majorVersion" => "v2025" },
        ],
      )
    end

    it "raises rather than publishing a malformed id" do
      expect { described_class.call }.to raise_error(Fauapi::PublishCatalogue::Error, /Ambiguous catalogue entries/)
      expect(Fauapi::Client).not_to have_received(:publish)
    end
  end

  context "when no manifests are generated" do
    let(:manifests) { [] }

    it "raises" do
      expect { described_class.call }.to raise_error(Fauapi::PublishCatalogue::Error, /No OpenAPI versions/)
    end
  end
end

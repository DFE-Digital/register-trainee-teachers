# frozen_string_literal: true

require "rails_helper"

RSpec.describe Fauapi::BuildManifests do
  subject(:manifests) { described_class.call }

  it "builds one manifest per academic year major" do
    expect(manifests.map { |m| m[:majorVersion] }).to eq(%w[v2025 v2026])
  end

  it "scopes releases to each major and tags the current version Live" do
    v2025 = manifests.find { |m| m[:majorVersion] == "v2025" }
    v2026 = manifests.find { |m| m[:majorVersion] == "v2026" }

    expect(v2025[:releases]).to contain_exactly(
      hash_including(name: "v2025.0", tag: "Deprecated", isCurrent: true),
    )
    expect(v2026[:releases]).to contain_exactly(
      hash_including(name: "v2026.1", tag: "Live", isCurrent: true),
    )
  end

  it "embeds base64-encoded OpenAPI yaml for the entry version" do
    v2026 = manifests.find { |m| m[:majorVersion] == "v2026" }
    decoded = Base64.strict_decode64(v2026.dig(:schema, :documentContentValue))

    expect(v2026.dig(:schema, :fileName)).to eq("v2026.1.yaml")
    expect(decoded).to eq(Rails.public_path.join("openapi/v2026.1.yaml").binread)
  end

  it "uses the configured api name" do
    expect(manifests.map { |m| m[:name] }.uniq).to eq([Settings.fauapi.api_name])
  end
end

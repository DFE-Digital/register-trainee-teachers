# frozen_string_literal: true

require "rails_helper"

describe "vendor:swap" do
  subject do
    args = Rake::TaskArguments.new(%i[vendor_name provider_id_to_replace], [vendor_name, provider_id_to_replace])
    Rake::Task["vendor:swap"].execute(args)
  end

  let(:existing_provider) { create(:provider) }
  let(:provider_id_to_replace) { existing_provider.id }
  let(:vendor_name) { "vendor name" }
  let(:swapped_message) { "Swapped: #{existing_provider.name_and_code} with #{vendor_name}" }
  let(:token) { AuthenticationToken.last.hashed_token }
  let(:token_message) { "Token: `not_for_production_#{token}`" }

  it "swapped the provider with vendor" do
    expect($stdout).to receive(:puts).with(swapped_message)
    expect(AuthenticationToken).to receive(:create_with_random_token).with(provider: existing_provider, created_by: existing_provider.users.first, name: "Token").and_call_original
    expect($stdout).to receive(:puts)

    expect {
      subject
      existing_provider.reload
    }.to change { existing_provider.name }.to(vendor_name)
     .and change { existing_provider.dttp_id }
     .and change { existing_provider.accreditation_id }
     .and change { existing_provider.ukprn }
     .and change { existing_provider.code }
     .and change { AuthenticationToken.all.reload.count }.from(0).to(1)
  end
end

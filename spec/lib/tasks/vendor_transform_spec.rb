# frozen_string_literal: true

require "rails_helper"

describe "vendor:transform" do
  subject do
    args = Rake::TaskArguments.new(%i[vendor_name provider_id_to_replace], [vendor_name, provider_id_to_replace])
    Rake::Task["vendor:transform"].execute(args)
  end

  let(:existing_provider) { create(:provider) }
  let(:provider_id_to_replace) { existing_provider.id }
  let(:vendor_name) { "vendor name" }
  let(:message) { "Transforming: #{existing_provider.name_and_code} to #{vendor_name}" }

  it "transformed the provider to a vendor" do
    expect($stdout).to receive(:puts).with(message)

    expect {
      subject
      existing_provider.reload
    }.to change { existing_provider.name }.to(vendor_name)
     .and change { existing_provider.dttp_id }
     .and change { existing_provider.accreditation_id }
     .and change { existing_provider.ukprn }
     .and change { existing_provider.code }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe SendCsvSubmittedForProcessingEmailService do
  before do
    enable_features(:send_emails)
    allow(CsvSubmittedForProcessingEmailMailer).to receive_message_chain(:generate, :deliver_later)
    described_class.call(user:, upload:)
  end

  let(:user) { create(:user) }
  let(:upload) { create(:bulk_update_trainee_upload) }

  it "sends the csv submitted for processing email" do
    expect(CsvSubmittedForProcessingEmailMailer).to have_received(:generate)
  end
end

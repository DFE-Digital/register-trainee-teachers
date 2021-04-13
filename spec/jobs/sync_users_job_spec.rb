# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncUsersJob do
    include ActiveJob::TestHelper

    let(:user_one_hash) { ApiStubs::Dttp::Contact.attributes }
    let(:user_two_hash) { ApiStubs::Dttp::Contact.attributes }
    let(:next_page_url) { "https://some-url.com" }

    let(:user_list) do
      {
        items: [user_one_hash, user_two_hash],
        meta: { next_page_url: next_page_url },
      }
    end

    subject { described_class.perform_now }

    before do
      allow(Dttp::RetrieveUsers).to receive(:call) { user_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp:User is not in register" do
      it "creates a Dttp::user record for each unique user" do
        expect {
          subject
        }.to change(Dttp::User, :count).by(2)
      end
    end

    context "when a Dttp::User exist" do
      let(:dttp_user) { create(:dttp_user, dttp_id: user_one_hash["contactid"]) }

      before do
        dttp_user
      end

      it "updates the existing record" do
        subject
        expect(dttp_user.reload.first_name).to eq(user_one_hash["firstname"])
      end
    end

    context "when next_page_url is not available" do
      let(:next_page_url) { nil }

      it "does not enqueue any further jobs" do
        expect {
          subject
        }.not_to have_enqueued_job(described_class)
      end
    end
  end
end

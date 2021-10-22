# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

# This spec is coupled to the Candidate model. I thought
# this was preferable to making an elaborate mock which
# didn't depend on the db
module BigQuery
  RSpec.describe EmitsEntityEvents do
    include ActiveJob::TestHelper
    let(:include_fields) { [] }

    before do
      enable_features("google.send_data_to_big_query")
      allow(Rails.configuration).to receive(:analytics).and_return({
        providers: include_fields,
      })
    end

    describe "create" do
      context "when an entity has configured fields to include" do
        let(:include_fields) { %w[name code] }

        before do
          create(:provider)
        end

        it "sends the event" do
          expect(SendEventJob).to have_been_enqueued
        end
      end

      context "when an entity does not have configured fields to include" do
        it "doesn't send an event" do
          expect(SendEventJob).not_to have_been_enqueued
        end
      end
    end

    describe "update" do
      before do
        provider = create(:provider)
        clear_enqueued_jobs
        provider.update(name: "Dave", code: "M1X")
      end

      context "when an entity has configured fields to include" do
        let(:include_fields) { %w[name code] }

        it "sends the event" do
          expect(SendEventJob).to have_been_enqueued
        end
      end

      context "when an entity does not have configured fields to include" do
        it "doesn't send an event" do
          expect(SendEventJob).not_to have_been_enqueued
        end
      end
    end

    describe "send_import_event" do
      let(:provider) { create(:provider) }

      before do
        provider
        clear_enqueued_jobs
      end

      it "sends an event" do
        provider.send_import_event
        expect(SendEventJob).to have_been_enqueued
      end

      it "sets the event type" do
        expect(provider.send_import_event.as_json["event_type"]).to eq("import_entity")
      end
    end
  end
end

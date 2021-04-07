# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimeline do
    let(:trainee) { create(:trainee) }
    let(:audits) { trainee.own_and_associated_audits }
    subject { described_class.call(audits: audits) }

    describe "#call" do
      context "when a trainee has been updated" do
        before do
          trainee.update!(first_names: "name")
          audits.each do |audit|
            timeline_event = double(title: "title", date: audit.created_at)
            allow(CreateTimelineEvents).to receive(:call).with(audit: audit).and_return(timeline_event)
          end
        end

        it "returns two timeline events" do
          expect(subject.count).to eq(2)
        end

        it "returns the events in reverse order" do
          expected_order = audits.pluck(:created_at).sort.reverse
          expect(subject.map(&:date)).to eq(expected_order)
        end
      end
    end
  end
end

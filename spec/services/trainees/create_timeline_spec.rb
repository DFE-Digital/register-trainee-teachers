# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimeline do
    let(:trainee) { create(:trainee) }
    let(:audits) { trainee.own_and_associated_audits }

    subject { described_class.call(trainee: trainee) }

    describe "#call" do
      context "when a trainee is updated but not yet submitted for trn" do
        before do
          update_name
          reload_audits
        end

        it "returns just the creation audit" do
          expect(subject.count).to eq(1)
        end
      end

      context "when a trainee has been submitted for trn" do
        before do
          trainee.submit_for_trn!
          reload_audits
        end

        it "returns the creation audit and the trn audit" do
          expect(subject.count).to eq(2)
        end

        context "and a subsequent update is made" do
          before do
            Timecop.travel(Time.zone.now + 1.hour) { update_name }
            reload_audits
          end

          it "returns the creation audit and the trn audit" do
            expect(subject.count).to eq(3)
          end
        end

        it "returns the events in reverse order" do
          expected_order = trainee.own_and_associated_audits.pluck(:created_at).sort.reverse
          expect(subject.map(&:date)).to eq(expected_order)
        end
      end

      context "when a trainee has been withdrawn" do
        let(:trainee) { create(:trainee, :trn_received) }

        before do
          trainee.withdraw_date = "2021-09-21"
          trainee.withdraw_reason = WithdrawalReasons::FOR_ANOTHER_REASON
          trainee.additional_withdraw_reason = "lost interest"
          trainee.withdraw!
        end

        it "returns the date of withdrawal in the correct format and reason" do
          expect(subject.first.items).to eq([["Date of withdrawal:", "21 September 2021"], ["Reason for withdrawal:", "Lost interest"]])
        end
      end
    end

    def update_name
      trainee.update!(first_names: "name")
    end

    def reload_audits
      trainee.own_and_associated_audits.each do |audit|
        allow(CreateTimelineEvents).to receive(:call).with(audit: audit).and_return(double(title: "title", date: audit.created_at))
      end
    end
  end
end

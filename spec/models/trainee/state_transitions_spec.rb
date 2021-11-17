# frozen_string_literal: true

require "rails_helper"

describe "Trainee state transitions" do
  describe "#award_qts!" do
    let(:awarded_at) { "2019-06-28T23:00:00Z" }
    let(:trainee) { create(:trainee, :recommended_for_award) }

    subject { trainee.award_qts!(awarded_at) }

    context "with a :recommended_for_award trainee" do
      it "transitions the trainee to :awarded and updates the awarded_at" do
        subject
        trainee.reload
        expect(trainee.state).to eq("awarded")
        expect(trainee.awarded_at).to eq(awarded_at)
      end
    end

    context "with no awarded_at date" do
      let(:awarded_at) { nil }

      it "raises an error if no awarded_at is provided" do
        expect {
          subject
        }.to raise_error(StateTransitionError)
      end
    end

    (Trainee.states.keys - %w[recommended_for_award]).each do |state|
      context "with a :#{state} trainee" do
        let(:trainee) { create(:trainee, state) }

        it "raises an error" do
          expect {
            subject
          }.to raise_error(RuntimeError, "Invalid transition")
        end
      end
    end
  end

  describe "#trn_received!" do
    let(:old_trn) { "123" }
    let(:new_trn) { "abc" }

    context "with a :submitted_for_trn trainee" do
      let(:trainee) { create(:trainee, :submitted_for_trn) }

      it "transitions the trainee to :trn_received and updates the trn" do
        trainee.trn_received!(new_trn)
        expect(trainee.state).to eq("trn_received")
        expect(trainee.trn).to eq(new_trn)
      end
    end

    context "with a :deferred trainee" do
      context "with an existing trn" do
        let(:trainee) { create(:trainee, :deferred, trn: old_trn) }

        it "doesnt transition the trainee to :trn_received" do
          trainee.trn_received!
          expect(trainee.state).to eq("deferred")
          expect(trainee.trn).to eq(old_trn)
        end
      end

      context "without an existing trn" do
        let(:trainee) { create(:trainee, :deferred, trn: nil) }

        it "raises an error if no trn is provided" do
          expect {
            trainee.trn_received!
          }.to raise_error(StateTransitionError)
        end

        it "updates the trn but not the trainee state" do
          trainee.trn_received!(new_trn)
          expect(trainee.state).to eq("deferred")
          expect(trainee.trn).to eq(new_trn)
        end
      end
    end

    context "with a :trn_received trainee" do
      context "with an existing trn" do
        let(:trainee) { create(:trainee, :trn_received, trn: old_trn) }

        it "updates the trn" do
          trainee.trn_received!
          expect(trainee.trn).to eq(old_trn)
        end
      end

      context "without an existing trn" do
        let(:trainee) { create(:trainee, :trn_received, trn: nil) }

        it "raises an error if no trn is provided" do
          expect {
            trainee.trn_received!
          }.to raise_error(StateTransitionError)
        end

        it "updates the trn but not the trainee state" do
          trainee.trn_received!(new_trn)
          expect(trainee.state).to eq("trn_received")
          expect(trainee.trn).to eq(new_trn)
        end
      end
    end

    context "with a :deferred trainee with an existing trn" do
      let(:trainee) { create(:trainee, :deferred, trn: old_trn) }

      it "doesnt update state or trn" do
        trainee.trn_received!
        expect(trainee.state).to eq("deferred")
        expect(trainee.trn).to eq(old_trn)
      end
    end

    context "with a :withdrawn trainee" do
      context "with an existing trn" do
        let(:trainee) { create(:trainee, :withdrawn, trn: old_trn) }

        it "doesnt update state or trn" do
          trainee.trn_received!
          expect(trainee.state).to eq("withdrawn")
          expect(trainee.trn).to eq(old_trn)
        end
      end

      context "without an existing trn" do
        let(:trainee) { create(:trainee, :withdrawn, trn: nil) }

        it "doesnt update state but updates trn" do
          trainee.trn_received!(new_trn)
          expect(trainee.state).to eq("withdrawn")
          expect(trainee.trn).to eq(new_trn)
        end
      end
    end

    (Trainee.states.keys - %w[submitted_for_trn deferred trn_received]).each do |state|
      context "with a :#{state} trainee" do
        let(:trainee) { create(:trainee, state) }

        it "raises an error" do
          expect {
            trainee.receive_trn!
          }.to raise_error(RuntimeError, "Invalid transition")
        end
      end
    end
  end

  describe "#update_and_submit_for_trn!" do
    let(:dttp_id) { SecureRandom.uuid }
    let(:placement_assignment_dttp_id) { SecureRandom.uuid }

    context "with a :draft trainee" do
      let(:trainee) { create(:trainee, :draft) }

      it "transitions the trainee to :submitted_for_trn and updates the dttp_id, placement_assignment_dttp_id and submitted_for_trn_at" do
        trainee.trn_requested!(dttp_id, placement_assignment_dttp_id)
        expect(trainee.dttp_id).to eq(dttp_id)
        expect(trainee.placement_assignment_dttp_id).to eq(placement_assignment_dttp_id)
      end
    end
  end

  describe "#submit_for_trn" do
    let(:time_now) { Time.zone.now }

    subject { create(:trainee, :draft) }

    before do
      allow(Time).to receive(:now).and_return(time_now)
      subject.submit_for_trn!
    end

    it "sets the #submitted_for_trn_at" do
      expect(subject.submitted_for_trn_at).to eq(time_now)
    end

    context "with an apply application" do
      let(:apply_application) do
        create(:apply_application, invalid_data: { "unmappable info": "unmappable value" })
      end

      subject { create(:trainee, :draft, apply_application: apply_application) }

      it "wipes out the apply application's invalid_data" do
        expect(apply_application.invalid_data).to be_nil
      end
    end
  end
end

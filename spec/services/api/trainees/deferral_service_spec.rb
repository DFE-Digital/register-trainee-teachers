# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Trainees::DeferralService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      let(:params) do
        {
          defer_date: Time.zone.today.iso8601,
        }
      end

      let(:trainee) { create(:trainee, :trn_received, commencement_status: :itt_started_on_time, trainee_start_date: nil) }

      it "returns true" do
        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_nil

        trainee.reload

        expect(trainee.deferred?).to be(true)
        expect(trainee.defer_date).to eq(Date.parse(params[:defer_date]))
        expect(trainee.trainee_start_date).to eq(TraineeStartStatusForm.new(trainee).trainee_start_date)
      end

      it "calls Trainees::Update to trigger TRS/DQT updates" do
        expect(::Trainees::Update).to receive(:call).with(trainee: trainee)
        subject.call(params, trainee)
      end

      context "with a defer_reason <= 500 characters" do
        let(:defer_reason) { Faker::Lorem.characters(number: 500) }

        it "returns true" do
          success, errors = subject.call(params.merge(defer_reason:), trainee)

          expect(success).to be(true)
          expect(errors).to be_nil

          trainee.reload

          expect(trainee.deferred?).to be(true)
          expect(trainee.defer_date).to eq(Date.parse(params[:defer_date]))
          expect(trainee.defer_reason).to eq(defer_reason)
          expect(trainee.trainee_start_date).to eq(TraineeStartStatusForm.new(trainee).trainee_start_date)
        end
      end
    end

    describe "failure" do
      let(:trainee) { create(:trainee, :trn_received) }

      context "when defer_date is nil" do
        let(:params) do
          {
            defer_date: nil,
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Defer date can't be blank")
          expect(trainee.deferred?).to be(false)
        end
      end

      context "when defer_date is empty" do
        let(:params) do
          {
            defer_date: "",
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Defer date can't be blank")
          expect(trainee.deferred?).to be(false)
        end
      end

      context "when defer_date is invalid" do
        let(:params) do
          {
            defer_date: "abc",
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Defer date is invalid")
          expect(trainee.deferred?).to be(false)
        end
      end

      context "when the defer_reason is > 500 characters" do
        let(:params) do
          {
            defer_date: Time.zone.today.iso8601,
            defer_reason: Faker::Lorem.characters(number: 501),
          }
        end

        it "returns false" do
          success, errors = subject.call(params, trainee)

          expect(success).to be(false)
          expect(errors.full_messages).to contain_exactly("Defer reason is too long (maximum is 500 characters)")
          expect(trainee.deferred?).to be(false)
        end
      end

      it "does not call Trainees::Update when deferral fails" do
        params = { defer_date: nil }
        expect(::Trainees::Update).not_to receive(:call)
        subject.call(params, trainee)
      end
    end

    context "when the trainee cannot be deferred" do
      let(:trainee) { create(:trainee) }
      let(:params) do
        {
          defer_date: Time.zone.today.iso8601,
        }
      end

      it "returns false" do
        success, errors = subject.call(params, trainee)

        expect(success).to be(false)
        expect(errors.full_messages).to contain_exactly("Trainee state is invalid must be one of [submitted_for_trn, trn_received]")
        expect(trainee.deferred?).to be(false)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Trainees::DeferralService do
  subject { described_class }

  describe "::call" do
    describe "success" do
      let(:trainee) { create(:trainee, :trn_received) }

      let(:params) do
        {
          defer_date: Time.zone.today.iso8601,
        }
      end

      it "returns true" do
        success, errors = subject.call(params, trainee)

        expect(success).to be(true)
        expect(errors).to be_nil

        trainee.reload

        expect(trainee.deferred?).to be(true)
        expect(trainee.defer_date).to eq(Date.parse(params[:defer_date]))
        expect(trainee.trainee_start_date).to eq(TraineeStartStatusForm.new(trainee).trainee_start_date)
      end
    end

    describe "failure" do
      context "when trainee commencement_status is not itt_not_yet_started" do
        let(:trainee) { create(:trainee) }

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
          end
        end

        context "when defer_date is invalid" do
          let(:params) do
            {
              defer_date: "123",
            }
          end

          it "returns false" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(false)
            expect(errors.full_messages).to contain_exactly("Defer date is invalid")
          end
        end

        context "when defer_date is before itt_start_date" do
          let(:trainee) { create(:trainee, :trn_received, :with_valid_itt_start_date) }
          let(:params) do
            {
              defer_date: (trainee.itt_start_date - 1.day).iso8601,
            }
          end

          it "returns false" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(false)
            expect(errors.full_messages).to contain_exactly("Defer date must not be before the ITT start date")
          end
        end
      end

      context "when trainee commencement_status is itt_not_yet_started" do
        let(:trainee) { create(:trainee, :trn_received, :itt_not_yet_started) }

        context "when defer_date is nil" do
          let(:params) do
            {
              defer_date: nil,
            }
          end

          it "returns true" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(true)
            expect(errors).to be_nil
          end
        end

        context "when defer_date is empty" do
          let(:params) do
            {
              defer_date: "",
            }
          end

          it "returns true" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(true)
            expect(errors).to be_nil
          end
        end

        context "when defer_date is invalid" do
          let(:params) do
            {
              defer_date: "123",
            }
          end

          it "returns true" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(true)
            expect(errors).to be_nil
          end
        end

        context "when defer_date is before itt_start_date" do
          let(:trainee) { create(:trainee, :trn_received, :itt_not_yet_started, :with_valid_itt_start_date) }
          let(:params) do
            {
              defer_date: (trainee.itt_start_date - 1.day).iso8601,
            }
          end

          it "returns true" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(true)
            expect(errors).to be_nil
          end
        end
      end

      context "when the trainee cannot be deferred" do
        let(:trainee) { create(:trainee, :deferred) }

        context "when defer_date is nil" do
          let(:params) do
            {
              defer_date: Time.zone.today.iso8601,
            }
          end

          it "returns false" do
            success, errors = subject.call(params, trainee)

            expect(success).to be(false)
            expect(errors.full_messages).to contain_exactly("Trainee state is invalid must be one of [submitted_for_trn, trn_received]")
          end
        end
      end
    end
  end
end
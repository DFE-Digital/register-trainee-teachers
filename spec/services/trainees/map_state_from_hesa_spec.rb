# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapStateFromHesa do
    let(:hesa_stub_attributes) { {} }
    let(:hesa_api_stub) { ApiStubs::HesaApi.new(hesa_stub_attributes) }
    let(:hesa_xml) { hesa_api_stub.raw_xml }
    let(:hesa_trainee) { ::Hesa::Parsers::IttRecord.to_attributes(student_node: hesa_api_stub.student_node) }
    let(:hesa_reason_for_leaving_codes) { ::Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING.invert }
    let(:hesa_mode_codes) { ::Hesa::CodeSets::Modes::MAPPING.invert }
    let(:hesa_trn) { Faker::Number.number(digits: 7) }
    let(:date_today) { Time.zone.today }

    subject { described_class.call(hesa_trainee:, trainee:) }

    context "when the trainee is new" do
      let(:trainee) { build(:trainee) }

      context "when the trainee has no 'reason for leaving'" do
        context "and has no HESA TRN" do
          let(:hesa_stub_attributes) do
            { reason_for_leaving: nil, trn: nil }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end

        context "and has a HESA TRN but does not have a Register TRN" do
          let(:hesa_stub_attributes) do
            { reason_for_leaving: nil, trn: hesa_trn }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end
      end

      context "when the trainee's reason for leaving is COMPLETED_WITH_CREDIT_OR_AWARD" do
        context "and has a HESA TRN but does not have a Register TRN" do
          let(:hesa_stub_attributes) do
            {
              reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD],
              trn: hesa_trn,
            }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end

        context "and has no HESA TRN" do
          let(:hesa_stub_attributes) do
            {
              reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD],
              trn: nil,
            }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end
      end

      context "when the trainee's reason for leaving is COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN" do
        context "and they have a HESA TRN but do not have Register TRN" do
          let(:hesa_stub_attributes) do
            {
              reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN],
              trn: hesa_trn,
            }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end

        context "and they have no HESA TRN" do
          let(:hesa_stub_attributes) do
            {
              reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN],
              trn: nil,
            }
          end

          it { is_expected.to eq(:submitted_for_trn) }
        end
      end

      context "when the trainee's reason for leaving is a valid withdrawal reason" do
        let(:hesa_stub_attributes) do
          {
            reason_for_leaving: hesa_reason_for_leaving_codes[WithdrawalReasons::DEATH],
            end_date: date_today,
          }
        end

        it { is_expected.to eq(:withdrawn) }
      end
    end

    context "when the trainee is persisted" do
      let(:register_trn) { nil }
      let(:trainee) { create(:trainee, trn: register_trn) }

      context "when the trainee's reason for leaving is COMPLETED_WITH_CREDIT_OR_AWARD" do
        let(:hesa_stub_attributes) do
          {
            reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD],
          }
        end

        it { is_expected.to be_falsey }
      end

      context "when the trainee's reason for leaving is COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN" do
        let(:hesa_stub_attributes) do
          {
            reason_for_leaving: hesa_reason_for_leaving_codes[::Hesa::CodeSets::ReasonsForLeavingCourse::COMPLETED_WITH_CREDIT_OR_AWARD_UNKNOWN],
          }
        end

        it { is_expected.to be_falsey }
      end

      context "when there's no TRN received from HESA, but a TRN in Register already" do
        let(:hesa_stub_attributes) { { reason_for_leaving: nil, trn: nil } }
        let(:register_trn) { "1234567" }

        it { is_expected.to eq(:trn_received) }
      end

      context "when a trainee has a dormant mode, reason for leaving and an end date" do
        let(:hesa_stub_attributes) do
          { reason_for_leaving: hesa_reason_for_leaving_codes[WithdrawalReasons::FOR_ANOTHER_REASON],
            end_date: date_today,
            mode: hesa_mode_codes[::Hesa::CodeSets::Modes::DORMANT_FULL_TIME] }
        end

        it { is_expected.to eq(:withdrawn) }
      end

      context "when a trainee has a dormant mode but reason for leaving is nil" do
        let(:hesa_stub_attributes) do
          { end_date: date_today,
            mode: hesa_mode_codes[::Hesa::CodeSets::Modes::DORMANT_FULL_TIME] }
        end

        it { is_expected.to eq(:deferred) }
      end

      context "when a trainee has already been awarded QTS" do
        let(:trainee) { create(:trainee, :awarded) }

        it { is_expected.to eq(:awarded) }
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapStateFromHesa do
    let(:hesa_stub_attributes) { {} }
    let(:hesa_api_stub) { ApiStubs::HesaApi.new(hesa_stub_attributes) }
    let(:hesa_xml) { hesa_api_stub.raw_xml }
    let(:hesa_trainee) { Hesa::Parsers::IttRecord.to_attributes(student_node: hesa_api_stub.student_node) }
    let(:hesa_reason_for_leaving_codes) { Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING.invert }
    let(:hesa_mode_codes) { Hesa::CodeSets::Modes::MAPPING.invert }
    let(:hesa_trn) { Faker::Number.number(digits: 7) }
    let(:date_today) { Time.zone.today }

    subject { described_class.call(hesa_trainee: hesa_trainee) }

    context "submitted_for_trn" do
      let(:hesa_stub_attributes) do
        { reason_for_leaving: nil, mode: nil, trn: nil }
      end

      it { is_expected.to eq(:submitted_for_trn) }
    end

    context "trn_received" do
      let(:hesa_stub_attributes) do
        { reason_for_leaving: nil, mode: nil, trn: hesa_trn }
      end

      it { is_expected.to eq(:trn_received) }

      context "course completed - result unknown" do
        let(:hesa_stub_attributes) do
          {
            mode: nil,
            trn: hesa_trn,
            reason_for_leaving: hesa_mode_codes[Hesa::CodeSets::ReasonsForLeavingCourse::UNKNOWN_COMPLETION],
          }
        end

        it { is_expected.to eq(:trn_received) }
      end
    end

    context "withdrawn" do
      let(:hesa_stub_attributes) do
        { reason_for_leaving: hesa_reason_for_leaving_codes[WithdrawalReasons::HEALTH_REASONS], end_date: date_today }
      end

      it { is_expected.to eq(:withdrawn) }
    end
  end
end

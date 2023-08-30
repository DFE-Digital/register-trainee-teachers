# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapStateFromHesa do
    let(:hesa_stub_attributes) { {} }
    let(:hesa_api_stub) { ApiStubs::HesaApi.new(hesa_stub_attributes) }
    let(:hesa_xml) { hesa_api_stub.raw_xml }
    let(:hesa_trainee) { ::Hesa::Parsers::IttRecord.to_attributes(student_node: hesa_api_stub.student_node) }
    let(:hesa_mode_codes) { ::Hesa::CodeSets::Modes::MAPPING.invert }
    let(:hesa_trn) { Faker::Number.number(digits: 7) }
    let(:date_today) { Time.zone.today }

    subject { described_class.call(hesa_trainee:, trainee:) }

    context "when the trainee is new" do
      let(:trainee) { build(:trainee) }

      it { is_expected.to be :submitted_for_trn }
    end

    context "when the trainee is persisted" do
      let(:register_trn) { nil }
      let(:trainee) { create(:trainee, trn: register_trn) }

      context "when there's no TRN received from HESA, but a TRN in Register already" do
        let(:register_trn) { "1234567" }

        it { is_expected.to eq(:trn_received) }
      end

      context "when a trainee has a dormant mode" do
        let(:hesa_stub_attributes) do
          { mode: hesa_mode_codes[::Hesa::CodeSets::Modes::DORMANT_FULL_TIME] }
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

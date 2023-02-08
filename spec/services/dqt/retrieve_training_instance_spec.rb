# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RetrieveTrainingInstance do
    let(:trainee) { create(:trainee, itt_start_date: Date.new(2021, 9, 7)) }
    let(:dqt_response) do
      {
        "trn" => "0123456",
        "firstName" => "Abigail",
        "lastName" => "McPhillips",
        "dateOfBirth" => "1991-07-04",
        "qtsDate" => nil,
        "eytsDate" => "2022-07-07",
        "initialTeacherTraining" => training_instances,
      }
    end
    let(:current_training_instance) {
      {
        "programmeStartDate" => "2021-09-07",
        "programmeEndDate" => "2022-07-29",
        "programmeType" => "EYITTGraduateEntry",
        "result" => "Pass",
        "provider" => { "ukprn" => "10005790" },
      }
    }

    subject { described_class.call(trainee:) }

    describe "#call" do
      before do
        allow(Dqt::Client).to receive(:get).and_return(dqt_response)
      end

      context "when there's a matching training instance" do
        let(:training_instances) { [current_training_instance] }

        it "returns the training instance" do
          expect(subject).to eq(current_training_instance)
        end
      end

      context "when there's multiple training instances" do
        let(:old_training_instance) {
          {
            "programmeStartDate" => "2020-09-07",
            "programmeEndDate" => "2021-07-29",
            "programmeType" => "ProviderLed",
            "result" => "Pass",
            "provider" => { "ukprn" => "10005790" },
          }
        }

        let(:training_instances) { [old_training_instance, current_training_instance] }

        it "returns the correct training instance" do
          expect(subject).to eq(current_training_instance)
        end
      end

      context "when there's no matching training instance" do
        let(:different_training_instance) {
          {
            "programmeStartDate" => "2021-09-08",
            "programmeEndDate" => "2022-07-29",
            "programmeType" => "EYITTGraduateEntry",
            "result" => "Pass",
            "provider" => { "ukprn" => "10005790" },
          }
        }

        let(:training_instances) { [different_training_instance] }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when there are no training instances" do
        let(:training_instances) { [] }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end

      context "when training instances is nil" do
        let(:training_instances) { nil }

        it "returns nil" do
          expect(subject).to be_nil
        end
      end
    end
  end
end

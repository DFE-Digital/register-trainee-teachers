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
    let(:expected_training_instance) {
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

      context "when there's only one training instance" do
        let(:training_instances) { [expected_training_instance] }

        it "returns the training instance" do
          expect(subject).to eq(expected_training_instance)
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

        let(:training_instances) { [old_training_instance, expected_training_instance] }

        it "returns the correct training instance" do
          expect(subject).to eq(expected_training_instance)
        end
      end
    end
  end
end

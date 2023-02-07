# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RetrieveTrainingInstance do
    let(:trainee) { create(:trainee, itt_start_date: Date.new(2021, 9, 7)) }
    let(:expected_training_instance) {
      {
        "programmeStartDate" => "2021-09-07",
        "programmeEndDate" => "2022-07-29",
        "programmeType" => "EYITTGraduateEntry",
        "result" => "Pass",
        "provider" => {
          "ukprn" => "10005790",
        },
      }
    }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:get).and_return(dqt_response)
      end

      subject { described_class.call(trainee:) }

      context "when there's only one training instance" do
        let(:dqt_response) do
          {
            "trn"=>"0123456",
            "firstName"=>"Abigail",
            "lastName"=>"McPhillips",
            "dateOfBirth"=>"1991-07-04",
            "nationalInsuranceNumber"=>nil,
            "hasActiveSanctions"=>false,
            "qtsDate"=>nil,
            "eytsDate"=>"2022-07-07",
            "earlyYearsStatus"=>{"value"=>"221", "name"=>"Early Years Teacher Status"},
            "initialTeacherTraining"=> [expected_training_instance],
          }
        end

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
            "provider" => {
              "ukprn" => "10005790",
            },
          }
        }

        let(:dqt_response) {
          {
            "trn"=>"0123456",
            "firstName"=>"Abigail",
            "lastName"=>"McPhillips",
            "dateOfBirth"=>"1991-07-04",
            "nationalInsuranceNumber"=>nil,
            "hasActiveSanctions"=>false,
            "qtsDate"=>nil,
            "eytsDate"=>"2022-07-07",
            "earlyYearsStatus"=>{"value"=>"221", "name"=>"Early Years Teacher Status"},
            "initialTeacherTraining"=> [old_training_instance, expected_training_instance],
          }
        }

        it "returns the correct training instance" do
          expect(subject).to eq(expected_training_instance)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe TraineeSafeToUnaward do
    let(:provider) { create(:provider) }
    let(:trainee) { create(:trainee, :trn_received, :early_years_postgrad, provider:) }
    let(:dqt_response) do
      {
        "trn" => "0123456",
        "firstName" => "Bob",
        "lastName" => "Roberts",
        "dateOfBirth" => "1980-01-01",
        "qtsDate" => nil,
        "eytsDate" => "2023-07-07",
        "initialTeacherTraining" => [current_training_instance],
      }
    end
    let(:current_training_instance) {
      {
        "programmeStartDate" => "2021-09-07",
        "programmeEndDate" => "2022-07-29",
        "programmeType" => "EYITTGraduateEntry",
        "result" => result,
        "provider" => { "ukprn" => provider.ukprn },
      }
    }

    describe "#call" do
      before do
        allow(Dqt::Client).to receive(:get).and_return(dqt_response)
      end

      context "when the trainee has passed training" do
        let(:result) { "Pass" }

        it "returns true" do
          expect(described_class.call(trainee)).to be(true)
        end
      end

      context "when the trainee has NOT passed training" do
        let(:result) { "ApplicationReceived" }

        it "returns false" do
          expect(described_class.call(trainee)).to be(false)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Trs
  module Params
    describe PersonalData do
      let(:trainee) do
        build(
          :trainee,
          first_names: "John",
          middle_names: "Michael",
          last_name: "Smith",
          sex: "male",
          email: "john.smith@example.com",
          date_of_birth: Date.new(1990, 1, 1),
        )
      end

      subject(:params) { described_class.new(trainee:) }

      describe "#to_json" do
        it "returns the expected JSON" do
          expected_json = {
            "firstName" => "John",
            "middleName" => "Michael",
            "lastName" => "Smith",
            "dateOfBirth" => "1990-01-01",
            "emailAddresses" => ["john.smith@example.com"],
            "gender" => "Male",
          }.to_json

          expect(params.to_json).to eq(expected_json)
        end
      end

      describe "gender mappings" do
        it "maps male correctly" do
          trainee.sex = "male"
          expect(JSON.parse(params.to_json)["gender"]).to eq("Male")
        end

        it "maps female correctly" do
          trainee.sex = "female"
          expect(JSON.parse(params.to_json)["gender"]).to eq("Female")
        end

        it "maps other correctly" do
          trainee.sex = "other"
          expect(JSON.parse(params.to_json)["gender"]).to eq("Other")
        end

        it "maps prefer_not_to_say correctly" do
          trainee.sex = "prefer_not_to_say"
          expect(JSON.parse(params.to_json)["gender"]).to eq("NotProvided")
        end

        it "maps sex_not_provided correctly" do
          trainee.sex = "sex_not_provided"
          expect(JSON.parse(params.to_json)["gender"]).to eq("NotAvailable")
        end
      end
    end
  end
end

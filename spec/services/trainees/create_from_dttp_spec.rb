# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttp do
    include SeedHelper

    let(:api_trainee) { create(:api_trainee) }
    let(:dttp_trainee) { create(:dttp_trainee, :with_placement_assignment, response: api_trainee) }

    subject(:create_trainee_from_dttp) { described_class.call(dttp_trainee: dttp_trainee) }

    context "when provider does not exist" do
      it "does not create a trainee" do
        expect {
          create_trainee_from_dttp
        }.not_to change(Trainee, :count)
      end
    end

    context "when placement assignment does not exist" do
      let(:dttp_trainee) { create(:dttp_trainee) }

      it "does not create a trainee" do
        expect {
          create_trainee_from_dttp
        }.not_to change(Trainee, :count)
      end
    end

    context "when a provider exists" do
      before { create(:provider, dttp_id: dttp_trainee.provider_dttp_id) }

      it "creates a trainee" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(1)
      end

      it "marks the dttp_trainee as processed" do
        expect {
          create_trainee_from_dttp
        }.to change(dttp_trainee, :state).to("processed")
      end

      it "creates a trainee with the dttp_trainee attributes" do
        create_trainee_from_dttp
        trainee = Trainee.last
        expect(trainee.first_names).to eq(api_trainee["firstname"])
        expect(trainee.last_name).to eq(api_trainee["lastname"])
        expect(trainee.address_line_one).to eq(api_trainee["address1_line1"])
        expect(trainee.address_line_two).to eq(api_trainee["address1_line2"])
        expect(trainee.town_city).to eq(api_trainee["address1_line3"])
        expect(trainee.postcode).to eq(api_trainee["address1_postalcode"])
        expect(trainee.email).to eq(api_trainee["emailaddress1"])
        expect(trainee.date_of_birth).to eq(Date.parse(api_trainee["birthdate"]))
        expect(trainee.gender).to eq("male")
        expect(trainee.trainee_id).to eq(api_trainee["dfe_traineeid"])
        expect(trainee.nationalities).to be_empty
        expect(trainee.trn).to eq(api_trainee["dfe_trn"].to_s)
      end

      context "when nationalities exist" do
        before do
          generate_seed_nationalities
        end

        it "adds the trainee's nationality" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.nationalities.map(&:name)).to match_array(["british"])
        end
      end

      context "when date of birth is blank" do
        let(:api_trainee) { create(:api_trainee, birthdate: "") }

        it "does not set date_of_birth" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.date_of_birth).to be_nil
        end
      end

      context "when gender is other" do
        let(:api_trainee) { create(:api_trainee, gendercode: "389040000") }

        it "maps gender to not provided" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.gender).to eq("gender_not_provided")
        end
      end

      context "when trainee_id is NOTPROVIDED" do
        let(:api_trainee) { create(:api_trainee, dfe_traineeid: "NOTPROVIDED") }

        it "sets the trainee id to blank" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.trainee_id).to be_nil
        end
      end

      context "when trainee already exists" do
        before { create(:trainee, dttp_id: dttp_trainee.dttp_id) }

        it "marks the application as a duplicate" do
          expect {
            create_trainee_from_dttp
          }.to change(Trainee, :count).by(0)
          .and change(dttp_trainee, :state).to("non_processable_duplicate")
        end
      end
    end
  end
end

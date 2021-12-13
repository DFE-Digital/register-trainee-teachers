# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttp do
    include SeedHelper

    let(:api_trainee) { create(:api_trainee) }
    let(:dttp_trainee) { create(:dttp_trainee, :with_placement_assignment, api_trainee_hash: api_trainee) }

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

    context "when the trainee is hpitt" do
      let(:dttp_trainee) { create(:dttp_trainee, :with_provider, :with_hpitt_placement_assignment) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_hpitt")
      end
    end

    context "when a provider exists" do
      let(:dttp_trainee) { create(:dttp_trainee, :with_placement_assignment, :with_provider, api_trainee_hash: api_trainee) }

      it "creates a trainee" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(1)
      end

      it "marks the dttp_trainee as imported" do
        expect {
          create_trainee_from_dttp
        }.to change(dttp_trainee, :state).to("imported")
      end

      it "creates a trainee with the dttp_trainee attributes" do
        create_trainee_from_dttp
        trainee = Trainee.last
        expect(trainee.first_names).to eq(api_trainee["firstname"])
        expect(trainee.last_name).to eq(api_trainee["lastname"])
        expect(trainee.locale_code).to eq("uk")
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

      context "with multiple placement_assignments" do
        let(:placement_assignment_one) do
          create(:dttp_placement_assignment,
                 response: create(:api_placement_assignment,
                                  dfe_programmestartdate: Faker::Date.in_date_period(year: Time.zone.now.year - 1, month: 9).strftime("%Y-%m-%d"),
                                  _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::RELIGIOUS_EDUCATION_DTTP_ID))
        end

        let(:placement_assignment_two) do
          create(:dttp_placement_assignment,
                 response: create(:api_placement_assignment,
                                  dfe_programmestartdate: Faker::Date.in_date_period(year: Time.zone.now.year, month: 9).strftime("%Y-%m-%d"),
                                  _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES_DTTP_ID))
        end

        let(:dttp_trainee) { create(:dttp_trainee, :with_provider, placement_assignments: [placement_assignment_one, placement_assignment_two]) }

        it "sets the course details from the latest placement assignment" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.course_subject_one).to eq(CourseSubjects::MODERN_LANGUAGES)
        end

        it "sets the trainee start date from the first placement assignment" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.commencement_date).to eq(placement_assignment_one.response["dfe_commencementdate"].to_date)
        end
      end

      context "with funding information available" do
        let(:api_placement_assignment) do
          create(:dttp_placement_assignment, response: create(:api_placement_assignment, :with_provider_led_bursary))
        end
        let(:dttp_trainee) { create(:dttp_trainee, :with_provider, placement_assignments: [api_placement_assignment]) }

        context "when scholarship" do
          let(:api_placement_assignment) do
            create(:dttp_placement_assignment, response: create(:api_placement_assignment, :with_scholarship))
          end

          it "sets scholarship" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.applying_for_scholarship).to eq(true)
          end
        end

        context "when funding method exists" do
          before do
            create(:funding_method, training_route: :provider_led_undergrad)
          end

          it "sets funding" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.applying_for_bursary).to eq(true)
          end
        end

        context "when funding method does not exist" do
          it "does not set funding" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.applying_for_bursary).to be_nil
          end
        end
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
          .and change(dttp_trainee, :state).to("non_importable_duplicate")
        end
      end
    end

    context "when training route is missing" do
      let(:api_placement_assignment) { create(:dttp_placement_assignment, response: create(:api_placement_assignment, _dfe_routeid_value: nil)) }
      let(:dttp_trainee) { create(:dttp_trainee, :with_provider, placement_assignments: [api_placement_assignment]) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_missing_route")
      end
    end

    context "when training state is not mapped" do
      let(:api_placement_assignment) { create(:dttp_placement_assignment, response: create(:api_placement_assignment, _dfe_traineestatusid_value: nil)) }
      let(:dttp_trainee) { create(:dttp_trainee, :with_provider, placement_assignments: [api_placement_assignment]) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_missing_state")
      end
    end
  end
end

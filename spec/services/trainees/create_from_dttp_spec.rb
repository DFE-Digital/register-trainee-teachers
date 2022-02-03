# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttp do
    include SeedHelper

    let(:api_trainee) { create(:api_trainee) }
    let(:provider) { create(:provider) }
    let(:api_placement_assignment) { create(:api_placement_assignment) }
    let(:placement_assignment) { create(:dttp_placement_assignment, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
    let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment], api_trainee_hash: api_trainee, provider: provider) }

    subject(:create_trainee_from_dttp) { described_class.call(dttp_trainee: dttp_trainee) }

    context "when provider does not exist" do
      let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment], api_trainee_hash: api_trainee, provider_dttp_id: nil) }

      it "does not create a trainee" do
        expect {
          create_trainee_from_dttp
        }.not_to change(Trainee, :count)
      end
    end

    context "when dttp_trainee is already imported" do
      let(:dttp_trainee) { create(:dttp_trainee, :with_provider, :with_placement_assignment, state: :imported) }

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

    context "when the trainee is merged" do
      let(:api_trainee) { create(:api_trainee, merged: true) }
      let(:dttp_trainee) { create(:dttp_trainee, :with_placement_assignment, :with_provider, api_trainee_hash: api_trainee) }

      it "does not create a trainee" do
        expect {
          create_trainee_from_dttp
        }.not_to change(Trainee, :count)
      end
    end

    context "when a provider exists" do
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
        expect(trainee.created_from_dttp).to be true
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
        expect(trainee.trn).to eq(api_trainee["dfe_trn"])
        expect(trainee.training_initiative).to eq("now_teach")
        expect(trainee.hesa_id).to eq(api_trainee["dfe_husid"])
        expect(trainee.dttp_update_sha).to eq(trainee.sha)
      end

      context "when the country is something other than England and has a non-uk postcode" do
        let(:api_trainee) { create(:api_trainee, address1_postalcode: nil, address1_country: "France") }

        it "sets the locale to non_uk" do
          create_trainee_from_dttp
          expect(Trainee.last.locale_code).to eq("non_uk")
        end
      end

      context "when neither address line one or postcode is present" do
        let(:api_trainee) { create(:api_trainee, address1_line1: nil, address1_postalcode: nil) }

        before do
          create_trainee_from_dttp
        end

        it "does not set the local to UK" do
          expect(Trainee.last.locale_code).to be nil
        end

        context "but the country is set to England" do
          let(:api_trainee) do
            create(:api_trainee, address1_line1: nil, address1_postalcode: nil, address1_country: "England")
          end

          it "sets the local to UK" do
            expect(Trainee.last.locale_code).to eq("uk")
          end
        end
      end

      context "when the trainee is on future_teaching_scholars" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_future_teaching_scholars_initiative) }
        let(:placement_assignment) { create(:dttp_placement_assignment, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
        let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment], provider_dttp_id: provider.dttp_id) }

        it "creates a trainee with school_direct_salaried route" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.training_route).to eq(TRAINING_ROUTE_ENUMS[:school_direct_salaried])
          expect(trainee.training_initiative).to eq("future_teaching_scholars")
        end
      end

      context "when the trainee is on an early_years route" do
        context "with no funding" do
          let(:dttp_trainee) { create(:dttp_trainee, :with_provider, :with_early_years_route) }

          it "sets the course subject one to early years and age range zero to five" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.course_subject_one).to eq(CourseSubjects::EARLY_YEARS_TEACHING)
            expect(trainee.course_age_range).to eq(AgeRange::ZERO_TO_FIVE)
          end
        end

        context "when the trainee has a grant" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_early_years_salaried_bursary) }
          let(:funding_method) { create(:funding_method, training_route: :early_years_salaried, funding_type: FUNDING_TYPE_ENUMS[:grant]) }
          let(:specialism) { create(:subject_specialism, subject_name: CourseSubjects::EARLY_YEARS_TEACHING) }

          before do
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: specialism.allocation_subject)
          end

          it "sets funding" do
            create_trainee_from_dttp
            expect(Trainee.last.applying_for_grant).to eq(true)
          end
        end
      end

      context "when the trainee is not on any initiative" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_initiative1id_value: nil) }

        it "creates a trainee with no training_initiative" do
          create_trainee_from_dttp
          expect(Trainee.last.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:no_initiative])
        end
      end

      context "when the trainee is provider_led_postgrad" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_undergrad, dfe_courselevel: Dttp::Params::PlacementAssignment::COURSE_LEVEL_PG) }

        it "creates a trainee with provider_led_postgrad route" do
          create_trainee_from_dttp
          expect(Trainee.last.training_route).to eq(TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
        end
      end

      context "when the trainee is provider_led_undergrad" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_undergrad, dfe_courselevel: Dttp::Params::PlacementAssignment::COURSE_LEVEL_UG) }

        it "creates a trainee with provider_led_undergrad route" do
          create_trainee_from_dttp
          expect(Trainee.last.training_route).to eq(TRAINING_ROUTE_ENUMS[:provider_led_undergrad])
        end
      end

      context "when the trainee is in a submitted_for_trn state" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: "275af972-9e1b-e711-80c7-0050568902d3") }

        before do
          allow(Dttp::RetrieveTrnJob).to receive(:perform_with_default_delay)
        end

        it "enqueues Dttp::RetrieveTrnJob job" do
          create_trainee_from_dttp
          expect(Dttp::RetrieveTrnJob).to have_received(:perform_with_default_delay).with(Trainee.last)
        end
      end

      context "when the trainee is in a recommended_for_award state" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: "1b5af972-9e1b-e711-80c7-0050568902d3") }

        before do
          allow(Dttp::RetrieveAwardJob).to receive(:perform_with_default_delay)
        end

        it "enqueues Dttp::RetrieveAwardJob job" do
          create_trainee_from_dttp
          expect(Dttp::RetrieveAwardJob).to have_received(:perform_with_default_delay).with(Trainee.last)
        end
      end

      context "when the trainee has an invalid non-digit TRN" do
        let(:api_trainee) { create(:api_trainee, :with_invalid_trn) }

        it "does not save the TRN" do
          create_trainee_from_dttp
          expect(Trainee.last.trn).to be nil
        end
      end

      context "when the trainee has an invalid TRN of 999999999" do
        let(:api_trainee) { create(:api_trainee, dfe_trn: "999999999") }

        it "does not save the TRN" do
          create_trainee_from_dttp
          expect(Trainee.last.trn).to be nil
        end
      end

      context "when the trainee has a valid TRN with whitespace" do
        let(:api_trainee) { create(:api_trainee, dfe_trn: "1065267 ") }

        it "trims whitespace and saves the TRN" do
          create_trainee_from_dttp
          expect(Trainee.last.trn).to eq("1065267")
        end
      end

      context "with primary subjects" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_ittsubject1id_value: "8ca12838-b3cf-e911-a860-000d3ab1da01") }

        it "sets the course education phase" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.course_education_phase).to eq("primary")
          expect(trainee.course_subject_one).to eq(CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS)
        end
      end

      context "with 'Primary Mathematics Specialist' as course subject" do
        let(:api_placement_assignment) do
          create(:api_placement_assignment,
                 _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::INACTIVE_MAPPING[::CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS][:entity_id])
        end

        it "sets the course subject one to Specialist Teaching" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.course_subject_one).to eq(CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS)
        end
      end

      context "with multiple placement_assignments" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_ittsubject1id_value: Dttp::CodeSets::CourseSubjects::MODERN_LANGUAGES_DTTP_ID) }
        let(:placement_assignment_one) { create(:dttp_placement_assignment, :with_academic_year_twenty_twenty_one, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
        let(:placement_assignment_two) { create(:dttp_placement_assignment, :with_academic_year_twenty_one_twenty_two, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
        let(:dttp_trainee) { create(:dttp_trainee, provider: provider, placement_assignments: [placement_assignment_one, placement_assignment_two]) }

        before { dttp_trainee.reload }

        it "sets the course details from the latest placement assignment" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.course_subject_one).to eq(CourseSubjects::MODERN_LANGUAGES)
          expect(trainee.commencement_date).to eq(placement_assignment_two.response["dfe_commencementdate"].to_date)
        end

        it "sets the trainee submitted_for_trn_at date from the first placement assignment" do
          create_trainee_from_dttp
          expect(Trainee.last.submitted_for_trn_at).to eq(placement_assignment_one.response["dfe_trnassessmentdate"].to_date)
        end
      end

      context "with funding information available" do
        context "when bursary is NO_BURSARY_AWARDED" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_no_bursary_awarded) }
          let(:funding_method) { create(:funding_method, training_route: :pg_teaching_apprenticeship, funding_type: FUNDING_TYPE_ENUMS[:scholarship]) }
          let(:specialism) { create(:subject_specialism, subject_name: CourseSubjects::MODERN_LANGUAGES) }

          before do
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: specialism.allocation_subject)
          end

          it "sets bursary to false" do
            create_trainee_from_dttp
            expect(Trainee.last.applying_for_bursary).to eq(false)
          end
        end

        context "when scholarship" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_scholarship) }
          let(:funding_method) { create(:funding_method, training_route: :provider_led_postgrad, funding_type: FUNDING_TYPE_ENUMS[:scholarship]) }
          let(:specialism) { create(:subject_specialism, subject_name: CourseSubjects::MODERN_LANGUAGES) }

          before do
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: specialism.allocation_subject)
          end

          it "sets scholarship" do
            create_trainee_from_dttp
            expect(Trainee.last.applying_for_scholarship).to eq(true)
          end
        end

        context "when bursary" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_bursary) }
          let(:funding_method) { create(:funding_method, training_route: :provider_led_postgrad, funding_type: FUNDING_TYPE_ENUMS[:bursary]) }
          let(:specialism) { create(:subject_specialism, subject_name: CourseSubjects::MODERN_LANGUAGES) }

          before do
            create(:funding_method_subject, funding_method: funding_method, allocation_subject: specialism.allocation_subject)
          end

          it "sets funding" do
            create_trainee_from_dttp
            expect(Trainee.last.applying_for_bursary).to eq(true)
          end
        end

        context "when multiple funding methods are available" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_bursary) }
          let(:bursary_funding_method) { create(:funding_method, training_route: :provider_led_postgrad, funding_type: FUNDING_TYPE_ENUMS[:bursary]) }
          let(:scholarship_funding_method) { create(:funding_method, training_route: :provider_led_postgrad, funding_type: FUNDING_TYPE_ENUMS[:scholarship]) }
          let(:specialism) { create(:subject_specialism, subject_name: CourseSubjects::MODERN_LANGUAGES) }

          before do
            create(:funding_method_subject, funding_method: bursary_funding_method, allocation_subject: specialism.allocation_subject)
            create(:funding_method_subject, funding_method: scholarship_funding_method, allocation_subject: specialism.allocation_subject)
          end

          it "sets the correct funding" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.applying_for_grant).to eq(nil)
            expect(trainee.applying_for_bursary).to eq(true)
            expect(trainee.applying_for_scholarship).to eq(nil)
          end
        end

        context "when funding method does not exist" do
          let(:api_placement_assignment) { create(:api_placement_assignment, :with_provider_led_bursary) }

          it "marks the application as non importable" do
            expect {
              create_trainee_from_dttp
            }.to change(Trainee, :count).by(0)
            .and change(dttp_trainee, :state).to("non_importable_missing_funding")
          end
        end
      end

      context "with tiered bursary funding" do
        let(:api_placement_assignment) { create(:api_placement_assignment, :with_tiered_bursary) }
        let(:placement_assignment) { create(:dttp_placement_assignment, provider_dttp_id: provider.dttp_id, response: api_placement_assignment) }
        let(:dttp_trainee) { create(:dttp_trainee, provider: provider, placement_assignments: [placement_assignment]) }

        it "sets bursary tier" do
          create_trainee_from_dttp
          trainee = Trainee.last
          expect(trainee.applying_for_bursary).to eq(true)
          expect(trainee.bursary_tier).to eq(BURSARY_TIER_ENUMS[:tier_two])
        end
      end

      context "when nationalities exist" do
        before do
          generate_seed_nationalities
        end

        it "adds the trainee's nationality" do
          create_trainee_from_dttp
          expect(Trainee.last.nationalities.map(&:name)).to match_array(["british"])
        end

        context "when the nationality is a uk nationality" do
          let(:api_trainee) { create(:api_trainee, :with_uk_nationality) }

          it "adds the trainee's nationality" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.nationalities.map(&:name)).to match_array(["british"])
          end
        end

        context "when the nationality is not known/supported" do
          let(:nationality) { Dttp::CodeSets::Nationalities::INACTIVE_MAPPING["American Samoa"][:entity_id] }
          let(:api_trainee) { create(:api_trainee, _dfe_nationality_value: nationality) }

          it "does not add the trainee's nationality" do
            create_trainee_from_dttp
            trainee = Trainee.last
            expect(trainee.nationalities).to be_empty
          end
        end

        Dttp::CodeSets::Nationalities::AMBIGUOUS_NATIONALITY_MAPPINGS.each do |nationality_name, ambiguous_mappings|
          context "when the nationality is #{nationality_name}" do
            let(:api_trainee) { create(:api_trainee, nationality_name: ambiguous_mappings.sample) }

            it "uses the non-ambiguous nationality name" do
              create_trainee_from_dttp
              trainee = Trainee.last
              expect(trainee.nationalities.map(&:name)).to match_array([nationality_name])
            end
          end
        end
      end

      %w[white scottish].each do |name|
        context "when ethnicity is #{name}" do
          let(:api_trainee) { create(:api_trainee, _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::INACTIVE_MAPPING[name][:entity_id]) }

          it "sets the ethnic_group to white and the ethnic_background to 'Not provided'" do
            create_trainee_from_dttp
            expect(Trainee.last.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:white])
            expect(Trainee.last.ethnic_background).to eq(Diversities::NOT_PROVIDED)
          end
        end
      end

      %w[information_not_yet_sought information_refused].each do |name|
        context "when ethnicity is #{name}" do
          let(:api_trainee) { create(:api_trainee, _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::INACTIVE_MAPPING[name][:entity_id]) }

          it "sets the ethnic_group to 'Not provided'" do
            create_trainee_from_dttp
            expect(Trainee.last.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          end
        end
      end

      context "when ethnicity is missing" do
        let(:api_trainee) { create(:api_trainee, _dfe_ethnicityid_value: nil) }

        it "sets the ethnic_group and background to 'Not provided'" do
          create_trainee_from_dttp
          expect(Trainee.last.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(Trainee.last.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when ethnicity is explicitly 'not provided'" do
        let(:api_trainee) { create(:api_trainee, _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::MAPPING[Diversities::NOT_PROVIDED][:entity_id]) }

        it "sets the ethnic_group and background to 'Not provided'" do
          create_trainee_from_dttp
          expect(Trainee.last.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(Trainee.last.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when neither ethnicity nor disabilities are disclosed" do
        let(:api_trainee) { create(:api_trainee, _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::INACTIVE_MAPPING["information_refused"][:entity_id]) }

        it "sets the diversity disclosure to 'diversity_not_disclosed'" do
          create_trainee_from_dttp
          expect(Trainee.last.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
        end
      end

      context "when just disability is disclosed" do
        let(:api_trainee) do
          create(
            :api_trainee,
            _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::INACTIVE_MAPPING["information_refused"][:entity_id],
            _dfe_disibilityid_value: "e798eae7-4ba5-e711-80da-005056ac45bb",
          )
        end

        it "sets the diversity disclosure to 'diversity_disclosed'" do
          create_trainee_from_dttp
          expect(Trainee.last.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
        end
      end

      context "when disability is 'MULTIPLE_DISABILITIES'" do
        let(:multiple_disability_id) { "d398eae7-4ba5-e711-80da-005056ac45bb" }
        let(:api_trainee) { create(:api_trainee, _dfe_disibilityid_value: multiple_disability_id) }

        before { create(:disability, name: Diversities::OTHER) }

        it "saves the disability as 'other' and sets the additional_diversity text" do
          create_trainee_from_dttp
          trainee_disability = Trainee.last.trainee_disabilities.last
          expect(trainee_disability.additional_disability).to eq(Trainees::CreateFromDttp::MULTIPLE_DISABILITIES_TEXT)
          expect(trainee_disability.disability.name).to eq(Diversities::OTHER)
        end
      end

      context "when just ethnicity is disclosed" do
        let(:api_trainee) do
          create(:api_trainee, _dfe_ethnicityid_value: Dttp::CodeSets::Ethnicities::MAPPING[Diversities::AFRICAN][:entity_id])
        end

        it "sets the diversity disclosure to 'diversity_disclosed'" do
          create_trainee_from_dttp
          expect(Trainee.last.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
        end
      end

      context "when date of birth is blank" do
        let(:api_trainee) { create(:api_trainee, birthdate: "") }

        it "does not set date_of_birth" do
          create_trainee_from_dttp
          expect(Trainee.last.date_of_birth).to be_nil
        end
      end

      context "when gender is other" do
        let(:api_trainee) { create(:api_trainee, gendercode: Dttp::Params::Contact::OTHER_GENDER_CODE) }

        it "maps gender to other" do
          create_trainee_from_dttp
          expect(Trainee.last.gender).to eq("other")
        end
      end

      context "when gender is nil" do
        let(:api_trainee) { create(:api_trainee, gendercode: nil) }

        it "maps gender to gender_not_provided" do
          create_trainee_from_dttp
          expect(Trainee.last.gender).to eq("gender_not_provided")
        end
      end

      context "when trainee_id is NOTPROVIDED" do
        let(:api_trainee) { create(:api_trainee, dfe_traineeid: "NOTPROVIDED") }

        it "sets the trainee id to blank" do
          create_trainee_from_dttp
          expect(Trainee.last.trainee_id).to be_nil
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
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_routeid_value: nil) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_missing_route")
      end
    end

    context "when placement assignments are from multiple providers" do
      let(:placement_assignment_one) { create(:dttp_placement_assignment, :with_academic_year_twenty_twenty_one) }
      let(:placement_assignment_two) { create(:dttp_placement_assignment, :with_academic_year_twenty_one_twenty_two, provider_dttp_id: provider.dttp_id) }
      let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment_one, placement_assignment_two], provider: provider) }

      it "imports the application" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(1)
        .and change(dttp_trainee, :state).to("imported")
      end
    end

    context "when the latest placement assignment provider does not match the contact provider" do
      let(:placement_assignment_one) { create(:dttp_placement_assignment, :with_academic_year_twenty_twenty_one, provider_dttp_id: provider.dttp_id) }
      let(:placement_assignment_two) { create(:dttp_placement_assignment, :with_academic_year_twenty_one_twenty_two) }
      let(:dttp_trainee) { create(:dttp_trainee, placement_assignments: [placement_assignment_one, placement_assignment_two], provider: provider) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_multi_provider")
      end
    end

    context "when placement assignments are having different courses" do
      let(:dttp_trainee) {
        create(:dttp_trainee,
               placement_assignments: create_list(:dttp_placement_assignment,
                                                  2,
                                                  provider_dttp_id: provider.dttp_id),
               provider_dttp_id: provider.dttp_id)
      }

      it "imports the application" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(1)
        .and change(dttp_trainee, :state).to("imported")
      end
    end

    context "when training_initiative is EBACC" do
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_initiative1id_value: Dttp::CodeSets::TrainingInitiatives::EBACC) }

      before do
        create_trainee_from_dttp
      end

      it "sets ebaac to true" do
        expect(Trainee.last.ebacc).to be true
      end

      it "sets no initiative" do
        expect(Trainee.last.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:no_initiative])
      end
    end

    context "when training_initiative is a primary mathematics specialism" do
      let(:api_placement_assignment) { create(:api_placement_assignment, :primary_mathematics_specialism) }

      before do
        create_trainee_from_dttp
      end

      it "sets no initiative and course subject to primary_mathematics_specialism" do
        expect(Trainee.last.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:no_initiative])
        expect(Trainee.last.course_subject_one).to eq(CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS)
      end
    end

    context "when training_initiative is not mapped" do
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_initiative1id_value: SecureRandom.uuid) }

      it "marks the application as non importable" do
        expect {
          create_trainee_from_dttp
        }.to change(Trainee, :count).by(0)
        .and change(dttp_trainee, :state).to("non_importable_missing_initiative")
      end
    end

    context "when the trainee is withdrawn" do
      let(:date) { Time.zone.today }
      let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_traineestatusid_value: "235af972-9e1b-e711-80c7-0050568902d3", dfe_dateleft: date, _dfe_reasonforleavingid_value: "436a46ad-11c2-e611-80be-00155d010316") }

      it "saves the withdraw date and reason" do
        create_trainee_from_dttp
        trainee = Trainee.last
        expect(trainee.withdraw_date).to eq date
        expect(trainee.withdraw_reason).to eq WithdrawalReasons::FOR_ANOTHER_REASON
      end
    end

    context "when the trainee has a dormant period" do
      let!(:dormant_period) do
        create(:dttp_dormant_period, placement_assignment_dttp_id: placement_assignment.dttp_id)
      end

      it "saves the deferral, reinstate_date, and dormancy_dttp_id" do
        create_trainee_from_dttp
        trainee = Trainee.last
        expect(trainee.defer_date).to eq(dormant_period.date_left.to_date)
        expect(trainee.reinstate_date).to eq(dormant_period.date_returned.to_date)
        expect(trainee.dormancy_dttp_id).to eq(dormant_period.dttp_id)
      end
    end

    context "when the trainee has a study mode that's not part or full time" do
      context "mappable to full time" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_studymodeid_value: "11640d4b-82b4-ea11-a812-000d3ad82cac") }

        it "maps it to full time" do
          create_trainee_from_dttp
          expect(Trainee.last.study_mode).to eq(COURSE_STUDY_MODES[:full_time])
        end
      end

      context "mappable to part time" do
        let(:api_placement_assignment) { create(:api_placement_assignment, _dfe_studymodeid_value: "db110557-82b4-ea11-a812-000d3ad82cac") }

        it "maps it to part time" do
          create_trainee_from_dttp
          expect(Trainee.last.study_mode).to eq(COURSE_STUDY_MODES[:part_time])
        end
      end
    end
  end
end

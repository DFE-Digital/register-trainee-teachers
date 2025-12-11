# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromHesa do
    let(:nationality_name) { RecruitsApi::CodeSets::Nationalities::MAPPING[student_attributes[:nationality]] }
    let(:hesa_api_stub) { ApiStubs::HesaApi.new(hesa_stub_attributes) }
    let(:student_attributes) { hesa_api_stub.student_attributes }
    let(:create_custom_state) { "implemented where necessary" }
    let(:hesa_stub_attributes) { {} }
    let(:hesa_trn) { Faker::Number.number(digits: 7).to_s }
    let(:trainee_degree) { trainee.degrees.first }
    let(:hesa_course_subject_codes) { ::Hesa::CodeSets::CourseSubjects::MAPPING.invert }
    let(:hesa_age_range_codes) { DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.invert }
    let!(:start_academic_cycle) { create(:academic_cycle, cycle_year: 2022) }
    let!(:end_academic_cycle) { create(:academic_cycle, cycle_year: 2023) }
    let!(:itt_reform_academic_cycle) { create(:academic_cycle, cycle_year: 2024) }
    let!(:after_next_academic_cycle) { create(:academic_cycle, one_after_next_cycle: true) }
    let(:first_disability_name) { Diversities::LEARNING_DIFFICULTY }
    let!(:first_disability) { create(:disability, name: first_disability_name) }
    let(:second_disability_name) { Diversities::DEVELOPMENT_CONDITION }
    let!(:second_disability) { create(:disability, name: second_disability_name) }
    let(:record_source) { Trainee::HESA_COLLECTION_SOURCE }
    let(:former_accredited_provider_ukprn) { described_class::LEAD_PARTNER_TO_ACCREDITED_PROVIDER_MAPPING.keys.sample }
    let(:accredited_provider_ukprn) { described_class::LEAD_PARTNER_TO_ACCREDITED_PROVIDER_MAPPING[former_accredited_provider_ukprn] }
    let(:school) { create(:school, urn: student_attributes[:lead_partner_urn]) }
    let(:duplicate_trainees) { [] }

    let!(:course_allocation_subject) do
      create(:subject_specialism, name: CourseSubjects::BIOLOGY).allocation_subject
    end

    subject(:trainee) { Trainee.first }

    before do
      allow(Trainees::Update).to receive(:call).with(trainee: instance_of(Trainee))
      allow(Sentry).to receive(:capture_message)
      allow(Trainees::FindDuplicatesOfHesaTrainee).to receive(:call).and_return(duplicate_trainees)
      create(:nationality, name: nationality_name)
      create(:provider, ukprn: student_attributes[:ukprn])
      create(:provider, ukprn: accredited_provider_ukprn)
      create(:training_partner, :hei, ukprn: former_accredited_provider_ukprn)
      create(:training_partner, :school, school:)
      create(:withdrawal_reason, :with_all_reasons)
      create_custom_state
    end

    after do
      FormStore.clear_all(trainee.id)
    end

    describe "HESA information imported from XML" do
      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )
      end

      it "updates the Trainee ID, HESA ID and record_source" do
        expect(trainee.provider_trainee_id).to eq(student_attributes[:provider_trainee_id])
        expect(trainee.hesa_id).to eq(student_attributes[:hesa_id])
        expect(trainee.record_source).to eq(record_source)
      end

      it "updates the trainee's personal details" do
        expect(trainee.first_names).to eq(student_attributes[:first_names])
        expect(trainee.last_name).to eq(student_attributes[:last_name])
        expect(trainee.sex).to eq("male")
        expect(trainee.date_of_birth).to eq(Date.parse(student_attributes[:date_of_birth]))
        expect(trainee.nationalities.pluck(:name)).to include(nationality_name)
        expect(trainee.email).to eq(student_attributes[:email])
      end

      it "associates the trainer to a provider" do
        expect(trainee.provider.ukprn).to eq(student_attributes[:ukprn])
      end

      it "updates trainee's course details" do
        expect(trainee.course_allocation_subject).to eq(course_allocation_subject)
        expect(trainee.course_education_phase).to eq(COURSE_EDUCATION_PHASE_ENUMS[:primary])
        expect(trainee.course_subject_one).to eq(::CourseSubjects::PRIMARY_TEACHING)
        expect(trainee.course_subject_two).to eq(::CourseSubjects::BIOLOGY)
        expect(trainee.course_subject_three).to be_nil
        expect(trainee.course_age_range).to eq(DfE::ReferenceData::AgeRanges::THREE_TO_SEVEN)
        expect(trainee.study_mode).to eq("full_time")
        expect(trainee.itt_start_date).to eq(Date.parse(student_attributes[:itt_start_date]))
        expect(trainee.itt_end_date).to eq(Date.parse(student_attributes[:itt_end_date]))
        expect(trainee.start_academic_cycle).to eq(start_academic_cycle)
        expect(trainee.end_academic_cycle).to eq(end_academic_cycle)
        expect(trainee.trainee_start_date).to eq(Date.parse(student_attributes[:trainee_start_date]))
      end

      it "updates the trainee's school and training details" do
        expect(trainee.training_partner.urn).to eq(student_attributes[:lead_partner_urn])
        expect(trainee.employing_school.urn).to eq(student_attributes[:employing_school_urn])
        expect(trainee.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools])
      end

      context "when training_partner_not_applicable was previously set to true" do
        before do
          trainee.update!(training_partner_not_applicable: true, training_partner_id: nil)
          described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          trainee.reload
        end

        it "updates the trainee's lead_partner and training_partner_not_applicable state" do
          expect(trainee.training_partner.urn).to eq(student_attributes[:lead_partner_urn])
          expect(trainee.training_partner_not_applicable).to be false
        end
      end

      context "when ukprn is from a formerly accredited HEI in academic year 2022" do
        let(:hesa_stub_attributes) { { ukprn: former_accredited_provider_ukprn } }

        it "sets the correct accredited provider and lead partner" do
          expect(trainee.provider.ukprn).to eq(former_accredited_provider_ukprn)
          expect(trainee.training_partner.urn).to eq(school.urn)
        end
      end

      context "when ukprn is from a formerly accredited HEI in academic year 2024" do
        let(:hesa_stub_attributes) do
          {
            ukprn: former_accredited_provider_ukprn,
            trainee_start_date: "2024-09-01",
          }
        end

        it "sets the correct accredited provider and lead partner" do
          expect(trainee.provider.ukprn).to eq(accredited_provider_ukprn)
          expect(trainee.training_partner.ukprn).to eq(former_accredited_provider_ukprn)
        end
      end

      it "updates the trainee's funding details" do
        expect(trainee.applying_for_bursary).to be(false)
        expect(trainee.applying_for_grant).to be(false)
        expect(trainee.applying_for_scholarship).to be(false)
      end

      it "creates the trainee's degree" do
        expect(trainee.degrees.count).to eq(student_attributes[:degrees].count)
        expect(trainee_degree.locale_code).to eq("uk")
        expect(trainee_degree.uk_degree).to eq("Master of Science")
        expect(trainee_degree.non_uk_degree).to be_nil
        expect(trainee_degree.subject).to eq("Pharmacy")
        expect(trainee_degree.institution).to eq("The Open University")
        expect(trainee_degree.graduation_year).to eq(2005)
        expect(trainee_degree.grade).to eq("First-class honours")
        expect(trainee_degree.other_grade).to be_nil
        expect(trainee_degree.country).to be_nil
      end

      it "creates a trainee HESA metadata record" do
        expect(trainee.hesa_metadatum.itt_aim).to eq("Both professional status and academic award")
        expect(trainee.hesa_metadatum.itt_qualification_aim).to eq("Masters, not by research")
        expect(trainee.hesa_metadatum.fundability).to eq("Eligible for funding from the DfE")
        expect(trainee.hesa_metadatum.course_programme_title).to eq("FE Course 1")
        expect(trainee.hesa_metadatum.placement_school_urn).to eq(900000)
        expect(trainee.hesa_metadatum.year_of_course).to eq("0")
      end

      context "leading and employing schools not applicable" do
        let(:not_applicable_or_not_available_hesa_code) { "900010" }
        let(:establishment_outside_england_and_wales_hesa_code) { "900000" }

        let(:hesa_stub_attributes) do
          {
            lead_partner_urn: not_applicable_or_not_available_hesa_code,
            employing_school_urn: establishment_outside_england_and_wales_hesa_code,
          }
        end

        it "marks the trainee's lead partner as not applicable" do
          expect(trainee.training_partner_not_applicable).to be(true)
        end

        it "marks the trainee's employing school as not applicable" do
          expect(trainee.employing_school_not_applicable).to be(true)
        end
      end

      context "when there's an trainee_start_date provided" do
        let(:hesa_stub_attributes) { { trainee_start_date: "2022-09-10" } }

        it "sets this as the trainee's start_date rather than using itt_start_date" do
          trainee_start_date = Date.parse(student_attributes[:trainee_start_date])
          expect(trainee.trainee_start_date).to eq(trainee_start_date)
        end
      end
    end

    context "when the trainee was originally created via the TRN data endpoint" do
      let(:existing_trn) { Faker::Number.number(digits: 7).to_s }
      let(:create_custom_state) do
        create(:trainee, hesa_id: student_attributes[:hesa_id], trn: existing_trn, record_source: Trainee::HESA_TRN_DATA_SOURCE)
      end

      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )
      end

      it "updates the trainee record source to be HESA collection" do
        expect(trainee.hesa_collection_record?).to be(true)
      end
    end

    context "when the trainee is submitted via TRN data" do
      let(:record_source) { Trainee::HESA_TRN_DATA_SOURCE }

      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )
      end

      it "sets record source to HESA_TRN_DATA" do
        expect(trainee.hesa_trn_data_record?).to be(true)
      end

      context "but was originally created via the collection endpoint" do
        let(:existing_trn) { Faker::Number.number(digits: 7).to_s }
        let(:create_custom_state) do
          create(:trainee, hesa_id: student_attributes[:hesa_id], trn: existing_trn, record_source: Trainee::HESA_COLLECTION_SOURCE)
        end

        it "does not update the trainee record source" do
          expect(trainee.hesa_collection_record?).to be(true)
        end
      end
    end

    context "trainee already exists and didn't come from HESA" do
      let(:existing_trn) { Faker::Number.number(digits: 7).to_s }
      let(:hesa_disability_codes) { ::Hesa::CodeSets::Disabilities::MAPPING.invert }
      let(:hesa_ethnicity_codes) { ::Hesa::CodeSets::Ethnicities::MAPPING.invert }
      let(:create_custom_state) { create(:trainee, hesa_id: student_attributes[:hesa_id], trn: existing_trn) }

      context "when ethnicity is missing" do
        let(:hesa_stub_attributes) { { ethnic_background: nil } }

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "sets the ethnic_group and background to 'Not provided'" do
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(trainee.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when ethnicity is explicitly 'not provided'" do
        let(:hesa_stub_attributes) do
          { ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED] }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "sets the ethnic_group and background to 'Not provided'" do
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
          expect(trainee.ethnic_background).to eq(Diversities::NOT_PROVIDED)
        end
      end

      context "when neither ethnicity nor disabilities are disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED],
            disability1: nil,
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "sets the diversity disclosure to 'diversity_not_disclosed'" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided])
        end
      end

      context "when disability is 'Not provided'" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED],
            disability1: hesa_disability_codes[Diversities::NOT_PROVIDED],
          }
        end

        before do
          trainee.disabilities << first_disability

          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "sets the disclosures to 'not_disclosed' and removes the disabilities" do
          trainee.reload

          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed])
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided])
          expect(trainee.disabilities).to be_empty
        end
      end

      context "when just disability is disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED],
            disability1: hesa_disability_codes[first_disability_name],
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "correctly sets the disclosures and the disability on the trainee" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled])
          expect(trainee.disabilities).to include(first_disability)
        end
      end

      context "when multiple disabilities are disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED],
            disability1: hesa_disability_codes[first_disability_name],
            disability2: hesa_disability_codes[second_disability_name],
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "correctly sets the disclosures and all the disabilities on the trainee" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
          expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled])
          expect(trainee.disabilities).to include(first_disability, second_disability)
        end
      end

      context "when disability is disclosed as No known disability" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::NOT_PROVIDED],
            disability1: hesa_disability_codes[Diversities::NO_KNOWN_DISABILITY],
          }
        end

        context "when the trainee does not have existing disabilities" do
          before do
            described_class.call(
              hesa_trainee: student_attributes,
              record_source: record_source,
            )
          end

          it "sets no disabilities on the trainee" do
            trainee.reload

            expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
            expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability])
            expect(trainee.disabilities).to be_empty
          end
        end

        context "when the trainee has existing disabilities" do
          before do
            trainee.disabilities << first_disability

            described_class.call(
              hesa_trainee: student_attributes,
              record_source: record_source,
            )
          end

          it "removes the disabilities" do
            trainee.reload

            expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
            expect(trainee.disability_disclosure).to eq(Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability])
            expect(trainee.disabilities).to be_empty
          end
        end
      end

      context "when hesa disability code is invalid" do
        let(:hesa_stub_attributes) do
          {
            course_subject_one: "invalid course subject one codeset",
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "raises an error" do
          expect(Sentry).to have_received(:capture_message).with("Unmapped fields [:course_subject_one] on trainee - id: #{trainee.provider_trainee_id} - record source: #{trainee.record_source}")
        end
      end

      context "when hesa code is invalid" do
        let(:hesa_stub_attributes) do
          {
            disability1: "disability not in codeset",
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "raises an error" do
          expect(Sentry).to have_received(:capture_message).with("Unmapped fields [:disability1] on trainee - id: #{trainee.provider_trainee_id} - record source: #{trainee.record_source}")
        end
      end

      context "when just ethnicity is disclosed" do
        let(:hesa_stub_attributes) do
          {
            ethnic_background: hesa_ethnicity_codes[Diversities::AFRICAN],
            disability1: hesa_disability_codes[Diversities::NOT_PROVIDED],
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "sets the diversity disclosure to 'diversity_disclosed' and the correct ethnic group and background" do
          expect(trainee.diversity_disclosure).to eq(Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed])
          expect(trainee.ethnic_group).to eq(Diversities::ETHNIC_GROUP_ENUMS[:black])
          expect(trainee.ethnic_background).to eq(Diversities::AFRICAN)
        end
      end

      context "when bursary is available" do
        let(:hesa_bursary_level_codes) { ::Hesa::CodeSets::BursaryLevels::MAPPING.invert }
        let(:hesa_stub_attributes) do
          { bursary_level: hesa_bursary_level_codes[CodeSets::BursaryDetails::UNDERGRADUATE_BURSARY] }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "uses the MapFundingFromDttpEntityId service to determine bursary information" do
          expect(trainee.applying_for_bursary).to be(true)
        end
      end

      context "when training initiative is available and mappable" do
        let(:hesa_training_initiative_codes) { ::Hesa::CodeSets::TrainingInitiatives::MAPPING.invert }
        let(:hesa_stub_attributes) do
          { training_initiative: hesa_training_initiative_codes[ROUTE_INITIATIVES_ENUMS[:now_teach]] }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "maps the the HESA code to the register enum" do
          expect(trainee.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:now_teach])
        end
      end

      context "when an Apply `application_choice_id` is available and mappable" do
        let(:hesa_stub_attributes) do
          {
            application_choice_id: 123456,
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "maps the `application_choice_id` to `Trainee#application_choice_id`" do
          expect(trainee.application_choice_id).to eq(123456)
        end
      end

      context "when bursary level indicates veteran teaching undergraduate bursary" do
        let(:hesa_stub_attributes) do
          { bursary_level: described_class::VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "maps the trainee to the veteran teaching undergraduate bursary" do
          expect(trainee.training_initiative).to eq(ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary])
        end
      end

      context "trainee's course is in the primary age but subject isn't" do
        let(:hesa_stub_attributes) do
          {
            course_age_range: hesa_age_range_codes[DfE::ReferenceData::AgeRanges::SEVEN_TO_ELEVEN],
            course_subject_one: hesa_course_subject_codes[CourseSubjects::DESIGN],
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "adds 'primary teaching' and places it in the course_subject_one column" do
          expect(trainee.course_subject_one).to eq(CourseSubjects::PRIMARY_TEACHING)
          expect(trainee.course_subject_two).to eq(CourseSubjects::DESIGN)
        end
      end

      context "trainee's course is in the primary age but primary subject not the first subject" do
        let(:hesa_stub_attributes) do
          {
            course_age_range: hesa_age_range_codes[DfE::ReferenceData::AgeRanges::SEVEN_TO_ELEVEN],
            course_subject_one: hesa_course_subject_codes[CourseSubjects::DESIGN],
            course_subject_two: hesa_course_subject_codes[CourseSubjects::PRIMARY_TEACHING],
          }
        end

        before do
          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "moves 'primary teaching' to be the first subject" do
          expect(trainee.course_subject_one).to eq(CourseSubjects::PRIMARY_TEACHING)
          expect(trainee.course_subject_two).to eq(CourseSubjects::DESIGN)
        end
      end
    end

    context "trainee is already awarded with conflicting data to hesa" do
      let(:create_custom_state) { create(:trainee, :awarded, itt_end_date: DateTime.new(2024, 5, 11), hesa_id: student_attributes[:hesa_id]) }

      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )
      end

      it "does not update the trainee" do
        expect(trainee.itt_end_date).to eq(DateTime.new(2024, 5, 11))
      end
    end

    context "when the trainee's itt start date has changed by more than 30 days" do
      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )

        trainee.update!(itt_start_date: DateTime.new(2023, 9, 20))
      end

      context "when the trainee is withdrawn" do
        before do
          trainee.update!(state: :withdrawn)
        end

        it "creates a new record" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.to change { Trainee.count }.by(1)
        end
      end

      context "when the trainee is awarded" do
        before do
          trainee.update!(state: :awarded)
        end

        it "creates a new record" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.to change { Trainee.count }.by(1)
        end
      end

      context "when the trainee is neither awarded nor withdrawn" do
        it "updates the existing trainee instead of creating a new one" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.not_to change { Trainee.count }
        end
      end
    end

    context "when the trainee's itt start date has not changed by more than 30 days" do
      before do
        described_class.call(
          hesa_trainee: student_attributes,
          record_source: record_source,
        )
      end

      context "when the trainee is withdrawn" do
        before do
          trainee.update!(state: :withdrawn)
        end

        it "does not create a new record" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.not_to change { Trainee.count }
        end

        it "does not update the existing trainee" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.not_to change { trainee }
        end
      end

      context "when the trainee is awarded" do
        before do
          trainee.update!(state: :awarded)
        end

        it "does not create a new record" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.not_to change { Trainee.count }
        end

        it "does not update the existing trainee" do
          expect {
            described_class.call(hesa_trainee: student_attributes, record_source: record_source)
          }.not_to change { trainee.reload }
        end
      end

      context "when the trainee is neither awarded nor withdrawn" do
        before do
          trainee.update!(state: :draft)

          described_class.call(
            hesa_trainee: student_attributes,
            record_source: record_source,
          )
        end

        it "updates the existing trainee" do
          expect(trainee.reload.state).to eq("submitted_for_trn")
        end
      end

      context "when there are multiple trainees for the same HESA ID that are neither withdrawn nor awarded" do
        let!(:latest_trainee) { create(:trainee, hesa_id: trainee.hesa_id, itt_start_date: DateTime.new(2022, 9, 20)) }

        before do
          trainee.update(itt_start_date: DateTime.new(2022, 9, 20))

          described_class.call(hesa_trainee: student_attributes, record_source: record_source)
        end

        it "does not update the trainee with the earlier created_at timestamp" do
          expect(trainee.reload.itt_start_date).to eq(DateTime.new(2022, 9, 20))
        end
      end
    end
  end
end

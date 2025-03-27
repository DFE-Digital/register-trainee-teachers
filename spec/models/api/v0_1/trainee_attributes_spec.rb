# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::TraineeAttributes do
  subject { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_names) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:diversity_disclosure) }
    it { is_expected.to validate_presence_of(:study_mode) }
    it { is_expected.to validate_presence_of(:hesa_id) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }

    it {
      expect(subject).to validate_inclusion_of(:nationality)
        .in_array(RecruitsApi::CodeSets::Nationalities::MAPPING.values).allow_blank
    }

    it {
      expect(subject).to validate_inclusion_of(:training_initiative)
        .in_array(
          Hesa::CodeSets::TrainingInitiatives::MAPPING.values + [ROUTE_INITIATIVES_ENUMS[:no_initiative]],
        )
    }

    describe "sex" do
      context "when empty" do
        subject { described_class.new(sex: "") }

        it {
          subject.validate

          expect(subject.errors[:sex]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(sex: nil) }

        it {
          subject.validate

          expect(subject.errors[:sex]).to contain_exactly("can't be blank")
        }
      end

      context "when not included in the list of HESA sexes" do
        subject { described_class.new(sex: 100) }

        it {
          subject.validate

          expect(subject.errors[:sex]).to contain_exactly("has invalid reference data values")
        }
      end

      context "when included in the list of HESA sexes" do
        Hesa::CodeSets::Sexes::MAPPING.each_value do |sex|
          subject { described_class.new(sex:) }

          it "is expected to allow #{sex}" do
            subject.validate

            expect(subject.errors[:sex]).to be_blank
          end
        end
      end
    end

    describe "course_subject_one" do
      context "when empty" do
        subject { described_class.new(course_subject_one: "") }

        it {
          subject.validate

          expect(subject.errors[:course_subject_one]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(course_subject_one: nil) }

        it {
          subject.validate

          expect(subject.errors[:course_subject_one]).to contain_exactly("can't be blank")
        }
      end

      context "when not included in the list of HESA course subjects" do
        subject { described_class.new(course_subject_one: "random subject") }

        it {
          subject.validate

          expect(subject.errors[:course_subject_one]).to contain_exactly("has invalid reference data values")
        }
      end

      context "when included in the list of HESA course subjects" do
        Hesa::CodeSets::CourseSubjects::MAPPING.each_value do |course_subject|
          subject { described_class.new(course_subject_one: course_subject) }

          before do
            subject.validate
          end

          it "is expected to allow #{course_subject}" do
            expect(subject.errors[:course_subject_one]).to be_blank
          end
        end
      end
    end

    %i[course_subject_two course_subject_three].each do |course_subject|
      it {
        expect(subject).to validate_inclusion_of(course_subject).in_array(
          Hesa::CodeSets::CourseSubjects::MAPPING.values,
        ).allow_blank
      }
    end

    describe "study_mode" do
      context "when empty" do
        subject { described_class.new(study_mode: "") }

        it {
          subject.validate

          expect(subject.errors[:study_mode]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(study_mode: nil) }

        it {
          subject.validate

          expect(subject.errors[:study_mode]).to contain_exactly("can't be blank")
        }
      end

      context "when not included in the list of HESA study modes" do
        subject { described_class.new(study_mode: 2) }

        it {
          subject.validate

          expect(subject.errors[:study_mode]).to contain_exactly("has invalid reference data values")
        }
      end

      context "when included in the list of HESA study modes" do
        TRAINEE_STUDY_MODE_ENUMS.each_key do |study_mode|
          subject { described_class.new(study_mode:) }

          it "is expected to allow #{study_mode}" do
            subject.validate

            expect(subject.errors[:study_mode]).to be_blank
          end
        end
      end
    end

    it {
      expect(subject).to validate_inclusion_of(:ethnicity)
        .in_array(Hesa::CodeSets::Ethnicities::MAPPING.values.uniq).allow_blank
    }

    describe "training_route" do
      it { is_expected.to validate_presence_of(:training_route) }

      describe "inclusion" do
        context "when trainee_start_date is present" do
          let!(:academic_cycle) { create(:academic_cycle, cycle_year:) }

          before do
            Timecop.travel academic_cycle.start_date

            subject.trainee_start_date = academic_cycle.start_date.iso8601
          end

          context "when AcademicCycle#start_date < 2023" do
            let(:cycle_year) { 2022 }

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values)
            end
          end

          context "when AcademicCycle::start_date == 2023" do
            let(:cycle_year) { 2023 }

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values)
            end
          end

          context "when AcademicCycle::start_date > 2023" do
            let(:cycle_year) { 2024 }

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values)
            end
          end

          context "when AcademicCycle::for_date is nil" do
            let(:cycle_year) { 2024 }

            before do
              allow(AcademicCycle).to receive(:for_date)
            end

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values)
            end
          end

          context "when AcademicCycle::for_date is 2021" do
            let(:cycle_year) { 2021 }

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values.excluding(TRAINING_ROUTE_ENUMS[:provider_led_postgrad]))
            end
          end

          context "when AcademicCycle::for_date is 2024" do
            let(:cycle_year) { 2024 }

            it do
              expect(subject).to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values)
            end
          end

          context "when trainee_start_date is not valid" do
            let(:cycle_year) { 2025 }

            before do
              Timecop.return
            end

            it do
              expect(subject).not_to validate_inclusion_of(:training_route)
                .in_array(Hesa::CodeSets::TrainingRoutes::MAPPING.values.excluding(TRAINING_ROUTE_ENUMS[:provider_led_postgrad]))
            end
          end
        end
      end
    end

    describe "date_of_birth" do
      it { is_expected.to validate_presence_of(:date_of_birth) }

      context "when valid" do
        before do
          subject.date_of_birth = Time.zone.today.iso8601
        end

        it do
          subject.validate

          expect(subject.errors[:date_of_birth]).to be_blank
        end
      end

      context "when invalid" do
        before do
          subject.date_of_birth = "14/11/23"
        end

        it do
          subject.validate

          expect(subject.errors[:date_of_birth]).to contain_exactly("is invalid")
        end
      end
    end

    describe "itt_start_date" do
      it { is_expected.to validate_presence_of(:itt_start_date) }

      context "when valid" do
        before do
          subject.itt_start_date = Time.zone.today.iso8601
        end

        it do
          subject.validate

          expect(subject.errors[:itt_start_date]).to be_blank
        end
      end

      context "when invalid" do
        before do
          subject.itt_start_date = "14/11/23"
        end

        it do
          subject.validate

          expect(subject.errors[:itt_start_date]).to contain_exactly("is invalid")
        end
      end
    end

    describe "itt_end_date" do
      it { is_expected.to validate_presence_of(:itt_end_date) }

      context "when valid" do
        before do
          subject.itt_end_date = Time.zone.today.iso8601
        end

        it do
          subject.validate

          expect(subject.errors[:itt_end_date]).to be_blank
        end
      end

      context "when invalid" do
        before do
          subject.itt_end_date = "14/11/23"
        end

        it do
          subject.validate

          expect(subject.errors[:itt_end_date]).to contain_exactly("is invalid")
        end
      end
    end

    describe "trainee_start_date" do
      context "when valid" do
        before do
          subject.trainee_start_date = Time.zone.today.iso8601
        end

        it do
          subject.validate

          expect(subject.errors[:trainee_start_date]).to be_blank
        end
      end

      context "when invalid" do
        before do
          subject.trainee_start_date = "14/11/23"
        end

        it do
          subject.validate

          expect(subject.errors[:trainee_start_date]).to contain_exactly("is invalid")
        end
      end
    end
  end

  describe "nested attribute validations" do
    let(:placement_attributes) { [Api::V01::PlacementAttributes.new({})] }
    let(:degrees_attributes) { [Api::V01::DegreeAttributes.new({})] }
    let(:nationalisations_attributes) { [Api::V01::NationalityAttributes.new({})] }
    let(:hesa_trainee_detail_attributes) { Api::V01::HesaTraineeDetailAttributes.new({}) }

    before do
      subject.placements_attributes = placement_attributes
      subject.degrees_attributes = degrees_attributes
      subject.nationalisations_attributes = nationalisations_attributes
      subject.hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
    end

    it "calls valid? on each placement attribute" do
      expect(placement_attributes).to all(receive(:valid?))
      subject.valid?
    end

    it "calls valid? on each degree attribute" do
      expect(degrees_attributes).to all(receive(:valid?))
      subject.valid?
    end

    it "calls valid? on each nationalisation attribute" do
      expect(nationalisations_attributes).to all(receive(:valid?))
      subject.valid?
    end

    it "calls valid? on the hesa_trainee_detail attribute" do
      expect(hesa_trainee_detail_attributes).to receive(:valid?)
      subject.valid?
    end
  end

  describe ".from_trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :disabled_with_disabilities_disclosed, :completed, sex: :prefer_not_to_say) }
    let(:blind_disability) { create(:disability, :blind) }
    let(:deaf_disability) { create(:disability, :deaf) }
    let(:trainee_disability) { trainee.disabilities.to_h { |disability| [:disability_id, disability.id] } }

    before do
      blind_disability
      deaf_disability
    end

    context "with empty params" do
      subject(:attributes) { described_class.from_trainee(trainee, {}) }

      it "pulls HesaTraineeDetail attributes from association" do
        expect(attributes.hesa_trainee_detail_attributes).to be_present

        Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.each do |attr|
          expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
        end
      end

      it "correct sets both hesa_disabilities & trainee_disabilities_attributes" do
        expect(attributes.hesa_trainee_detail_attributes.hesa_disabilities).to match({ "disability1" => "55" })
        expect(attributes.trainee_disabilities_attributes).to match([trainee_disability])
      end

      it "correctly sets the sex attribute as an integer" do
        expect(attributes.sex).to eq(Trainee.sexes[:prefer_not_to_say])
      end
    end

    context "with additional hesa_disabilities disability2" do
      subject(:attributes) { described_class.from_trainee(trainee, { hesa_disabilities: { "disability2" => "58" } }) }

      it "pulls HesaTraineeDetail attributes from association" do
        expect(attributes.hesa_trainee_detail_attributes).to be_present

        Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.each do |attr|
          expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
        end
      end

      it "correct sets both hesa_disabilities & trainee_disabilities_attributes" do
        expect(attributes.hesa_trainee_detail_attributes.hesa_disabilities).to match({ "disability1" => "55", "disability2" => "58" })
        expect(attributes.trainee_disabilities_attributes).to match([trainee_disability, { disability_id: blind_disability.id }])
      end
    end

    context "with replacing hesa_disabilities disability1" do
      subject(:attributes) { described_class.from_trainee(trainee, { hesa_disabilities: { "disability1" => "58" } }) }

      it "pulls HesaTraineeDetail attributes from association" do
        expect(attributes.hesa_trainee_detail_attributes).to be_present

        Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.each do |attr|
          expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
        end
      end

      it "correct sets both hesa_disabilities & trainee_disabilities_attributes" do
        expect(attributes.hesa_trainee_detail_attributes.hesa_disabilities).to match({ "disability1" => "58" })
        expect(attributes.trainee_disabilities_attributes).to match([{ disability_id: blind_disability.id }])
      end
    end

    context "with replacing hesa_disabilities disability1 and adding hesa_disabilities disability2" do
      subject(:attributes) { described_class.from_trainee(trainee, { hesa_disabilities: { "disability1" => "57", "disability2" => "58" } }) }

      it "pulls HesaTraineeDetail attributes from association" do
        expect(attributes.hesa_trainee_detail_attributes).to be_present

        Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.each do |attr|
          expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
        end
      end

      it "correct sets both hesa_disabilities & trainee_disabilities_attributes" do
        expect(attributes.hesa_trainee_detail_attributes.hesa_disabilities).to match({ "disability1" => "57", "disability2" => "58" })
        expect(attributes.trainee_disabilities_attributes).to match([{ disability_id: deaf_disability.id }, { disability_id: blind_disability.id }])
      end
    end

    context "with hesa_disabilities disability1 set to blank and disability2 set to null" do
      subject(:attributes) { described_class.from_trainee(trainee, { hesa_disabilities: { "disability1" => "", "disability2" => "null" } }) }

      it "pulls HesaTraineeDetail attributes from association" do
        expect(attributes.hesa_trainee_detail_attributes).to be_present

        Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.each do |attr|
          expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
        end
      end

      it "correct sets both hesa_disabilities & trainee_disabilities_attributes" do
        expect(attributes.hesa_trainee_detail_attributes.hesa_disabilities).to match({ "disability1" => "", "disability2" => "null" })
        expect(attributes.trainee_disabilities_attributes).to be_empty
      end
    end
  end

  describe "#deep_attributes" do
    let(:params) do
      {
        first_names: "Orval",
        last_name: "Erdman",
        email: "Orval.Erdman@example.com",
        middle_names: "Strosin",
        training_route: "assessment_only",
        sex: "prefer_not_to_say",
        diversity_disclosure: "diversity_not_disclosed",
        ethnic_group: nil,
        ethnic_background: nil,
        disability_disclosure: nil,
        course_subject_one: "mathematics",
        trn: nil,
        course_subject_two: nil,
        course_subject_three: nil,
        study_mode: "full_time",
        application_choice_id: nil,
        previous_last_name: "Mueller",
        itt_aim: "201",
        course_study_mode: "01",
        course_year: 2024,
        course_age_range: "13918",
        pg_apprenticeship_start_date: 2.months.from_now.iso8601,
        funding_method: "13919",
        ni_number: "QQ 12 34 56 C",
      }
    end

    subject(:attributes) { described_class.new(params) }

    it "wraps all hesa trainee detail attributes" do
      deep_attributes = attributes.deep_attributes.with_indifferent_access

      expect(deep_attributes).to have_key(:hesa_trainee_detail_attributes)
    end
  end

  describe "assign_attributes" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :completed, sex: :prefer_not_to_say) }
    let(:trainee_attributes) { described_class.from_trainee(trainee, {}) }

    subject(:attributes) {
      trainee_attributes
    }

    it "correctly sets the sex attribute as an integer" do
      expect(attributes.sex).to eq(Trainee.sexes[trainee.sex])

      expect {
        attributes.assign_attributes(sex: 3)
      }.to change {
        attributes.sex
      }.from(4).to(3)
    end

    context "hesa trainee detail attributes" do
      context "changing a non hesa trainee detail attributes" do
        it "does not change the hesa trainee detail attributes" do
          expect(attributes.sex).to eq(Trainee.sexes[:prefer_not_to_say])

          expect {
            attributes.assign_attributes(sex: 3)
          }.not_to change {
            attributes.hesa_trainee_detail_attributes
          }
        end
      end

      context "changing a single hesa trainee detail attribute" do
        let(:trainee) { create(:trainee, :with_hesa_student, :completed, sex: :prefer_not_to_say, hesa_trainee_detail: hesa_trainee_detail) }

        let(:hesa_trainee_detail) {
          build(:hesa_trainee_detail, course_age_range: "13909")
        }

        let(:hesa_trainee_detail_attributes) {
          hesa_trainee_detail.attributes.select { |k, _v|
            Api::V01::HesaTraineeDetailAttributes::ATTRIBUTES.include?(k.to_sym)
          }
        }

        let(:updated_hesa_trainee_detail_attributes) {
          hesa_trainee_detail_attributes.merge("course_age_range" => "13919")
        }

        it "does not change the other hesa trainee detail attributes" do
          expect(attributes.hesa_trainee_detail_attributes.attributes).to match(hesa_trainee_detail_attributes)

          expect {
            attributes.assign_attributes(course_age_range: "13919")
          }.to change {
            attributes.hesa_trainee_detail_attributes.attributes
          }.from(hesa_trainee_detail_attributes).to(updated_hesa_trainee_detail_attributes)
        end
      end
    end
  end
end

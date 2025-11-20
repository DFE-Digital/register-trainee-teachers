# frozen_string_literal: true

require "rails_helper"

describe CourseDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  context "with primary education phase" do
    let(:trainee) do
      build(:trainee,
            :with_primary_education,
            course_subject_one: CourseSubjects::PRIMARY_TEACHING,
            course_subject_two: CourseSubjects::ENGLISH_STUDIES)
    end

    it "sets the primary_course_subjects from the course subject values" do
      expect(subject.primary_course_subjects).to eq(PublishSubjects::PRIMARY_WITH_ENGLISH)
    end

    context "with no subjects selected yet" do
      let(:trainee) { build(:trainee, :with_primary_education) }

      it "sets the primary_course_subjects from the course subject values" do
        expect(subject.primary_course_subjects).to be_nil
      end
    end
  end

  context "with early years route" do
    let(:trainee) { build(:trainee, training_route: "early_years_postgrad") }
    let!(:ey_allocation_subject) { create(:subject_specialism, name: CourseSubjects::EARLY_YEARS_TEACHING).allocation_subject }

    it "sets the correct course subject and allocation subject" do
      expect(subject.course_subject_one).to eq(CourseSubjects::EARLY_YEARS_TEACHING)
      expect(subject.course_allocation_subject).to eq(ey_allocation_subject)
    end
  end

  describe "before validation" do
    describe "#sanitise_course_dates" do
      let(:params) do
        {
          start_day: "1 2",
          start_month: "1 1",
          start_year: "2 0 2 0",
          end_day: "1 2",
          end_month: "1 1",
          end_year: "2 0 2 1",
        }
      end

      before { subject.valid? }

      it "does not return course date errors" do
        expect(subject.errors[:itt_start_date]).to be_empty
        expect(subject.errors[:itt_end_date]).to be_empty
      end
    end
  end

  describe "validations" do
    context "with primary education phase" do
      let(:trainee) { build(:trainee, :with_primary_education) }

      it { is_expected.not_to validate_presence_of(:course_subject_one) }
      it { is_expected.to validate_presence_of(:primary_course_subjects) }

      it {
        expect(subject).to validate_inclusion_of(:primary_course_subjects)
        .in_array(PUBLISH_PRIMARY_SUBJECTS)
      }

      context 'when "Primary with another subject" is selected' do
        let(:params) do
          {
            primary_course_subjects: :other,
          }
        end

        it "returns an error against subject two" do
          subject.valid?
          expect(subject.errors[:course_subject_two]).not_to be_empty
        end
      end

      context "with an early_years trainee" do
        let(:trainee) { build(:trainee, :with_primary_education, :early_years_undergrad) }

        it { is_expected.not_to validate_presence_of(:primary_course_subjects) }
      end
    end

    it { is_expected.to validate_presence_of(:course_subject_one) }

    context "when subjects are duplicated" do
      let(:params) do
        {
          course_subject_one: "Psychology",
          course_subject_two: "Psychology",
          course_subject_three: "Psychology",
        }
      end

      before do
        subject.valid?
      end

      it "returns an error against subject two" do
        expect(subject.errors[:course_subject_two]).not_to be_empty
      end

      it "returns an error against subject three" do
        expect(subject.errors[:course_subject_three]).not_to be_empty
      end
    end

    context "when the first and third subjects are provided" do
      let(:params) do
        {
          course_subject_one: "Psychology",
          course_subject_one_raw: "Psychology",
          course_subject_two: "",
          course_subject_two_raw: "",
          course_subject_three: "Mathematics",
          course_subject_three_raw: "Mathematics",
        }
      end

      before do
        subject.valid?
      end

      it "populates subject two with the third subject" do
        expect(subject.course_subject_two).to eq("Mathematics")
        expect(subject.course_subject_two_raw).to eq("Mathematics")
      end

      it "clears the third subject slot" do
        expect(subject.course_subject_three).to be_blank
        expect(subject.course_subject_three_raw).to be_blank
      end
    end

    describe "custom" do
      let(:translation_key_prefix) { "activemodel.errors.models.course_details_form.attributes" }

      before do
        subject.assign_attributes(attributes)
        subject.valid?
      end

      describe "#age_range_valid" do
        let(:attributes) do
          { main_age_range: }
        end

        context "main age range is blank" do
          let(:main_age_range) { "" }

          it "returns an error" do
            expect(subject.errors[:main_age_range]).to include(
              I18n.t(
                "#{translation_key_prefix}.main_age_range.blank",
              ),
            )
          end
        end

        context "main age range is 3 to 11" do
          let(:main_age_range) { "3 to 11" }

          it "does not return an error message for main age range" do
            expect(subject.errors[:main_age_range]).to be_empty
          end
        end

        context "main age range is other" do
          let(:attributes) do
            { main_age_range: :other,
              additional_age_range: additional_age_range }
          end

          context "additional age range is blank" do
            let(:additional_age_range) { "" }

            it "returns an error message for age range is blank" do
              expect(subject.errors[:additional_age_range]).to include(I18n.t(
                                                                         "#{translation_key_prefix}.main_age_range.blank",
                                                                       ))
            end
          end

          context "additional age range is 0 to 5" do
            let(:additional_age_range) { "0 to 5" }

            it "does not return an error message for additional age range" do
              expect(subject.errors[:additional_age_range]).to be_empty
            end
          end
        end
      end

      context "date attributes" do
        let(:attributes) do
          {
            **end_date_attributes,
            **start_date_attributes,
          }
        end

        date_error_message = "date error message"

        shared_examples date_error_message do |attribute_name, translation_key_suffix, day, month, year|
          if attribute_name == :itt_start_date
            let(:start_date_attributes) do
              { start_day: day, start_month: month, start_year: year }
            end
          else
            let(:end_date_attributes) do
              { end_day: day, end_month: month, end_year: year }
            end
          end

          let(:translation) do
            I18n.t(
              "#{translation_key_prefix}.#{attribute_name}.#{translation_key_suffix}",
            )
          end

          it "returns an error message for #{attribute_name.to_s.humanize} due to #{translation_key_suffix.to_s.humanize(capitalize: false)}" do
            expect(subject.errors[attribute_name]).to include(translation)
          end
        end

        describe "#itt_start_date_valid" do
          let(:end_date_attributes) { {} }
          let(:academic_cycle) { build(:academic_cycle, start_date: "2021-09-01", end_date: "2022-08-31") }

          before do
            # rubocop:disable RSpec/SubjectStub
            allow(subject).to receive(:academic_cycle).and_return(academic_cycle)
            # rubocop:enable RSpec/SubjectStub
            subject.valid?
          end

          context "the start date fields are 12/11/2020" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2020" }
            end

            let(:academic_cycle) { build(:academic_cycle, start_date: "2020-09-01", end_date: "2021-08-31") }

            before do
              # rubocop:disable RSpec/SubjectStub
              allow(subject).to receive(:academic_cycle).and_return(academic_cycle)
              # rubocop:enable RSpec/SubjectStub
              subject.valid?
            end

            it "does not return an error message for itt start date" do
              expect(subject.errors[:itt_start_date]).to be_empty
            end
          end

          context "the start date fields are 01/08/#{current_academic_year}" do
            let(:start_date_attributes) do
              { start_day: "01", start_month: "08", start_year: current_academic_year }
            end

            let(:academic_cycle) { build(:academic_cycle) }

            before do
              # rubocop:disable RSpec/SubjectStub
              allow(subject).to receive(:academic_cycle).and_return(academic_cycle)
              # rubocop:enable RSpec/SubjectStub
              subject.valid?
            end

            it "does not return an error message for itt start date" do
              expect(subject.errors[:itt_start_date]).to be_empty
            end
          end

          it_behaves_like date_error_message, :itt_start_date, :blank,
                          "", "", ""
          it_behaves_like date_error_message, :itt_start_date, :invalid,
                          "foo", "foo", "foo"

          it_behaves_like date_error_message, :itt_start_date, :too_old,
                          10.years.ago.day, 10.years.ago.month, 10.years.ago.year

          context "the start date fields are too far in future" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2099" }
            end

            it "returns an error message for itt start date" do
              expect(subject.errors.messages[:itt_start_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.itt_start_date.future")
            end
          end

          context "the start date fields are too far in past" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2000" }
            end

            let(:academic_cycle) { build(:academic_cycle, start_date: "2021-09-01", end_date: "2022-08-31") }

            before do
              # rubocop:disable RSpec/SubjectStub
              allow(subject).to receive(:academic_cycle).and_return(academic_cycle)
              # rubocop:enable RSpec/SubjectStub
              subject.valid?
            end

            it "returns an error message for itt start date" do
              expect(subject.errors.messages[:itt_start_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.itt_start_date.too_old")
            end
          end
        end

        describe "#itt_end_date_valid" do
          let(:start_date) { 1.month.ago }

          let(:start_date_attributes) do
            {
              start_day: start_date.day,
              start_month: start_date.month,
              start_year: start_date.year,
            }
          end

          context "the end date fields are after start date" do
            let(:end_date_attributes) do
              {
                end_day: start_date.day,
                end_month: start_date.month,
                end_year: start_date.year + 1,
              }
            end

            it "does not return an error message for end date" do
              expect(subject.errors[:itt_end_date]).to be_empty
            end
          end

          it_behaves_like date_error_message, :itt_end_date, :blank,
                          "", "", ""
          it_behaves_like date_error_message, :itt_end_date, :invalid,
                          "foo", "foo", "foo"
          it_behaves_like date_error_message, :itt_end_date, :before_or_same_as_start_date,
                          1.month.ago.day, 1.month.ago.month, 1.month.ago.year
          it_behaves_like date_error_message, :itt_end_date, :before_or_same_as_start_date,
                          1.month.ago.day, 1.month.ago.month, 1.month.ago.year - 1

          context "the end date fields are too far in future" do
            let(:end_date_attributes) do
              { end_day: "12", end_month: "11", end_year: "3000" }
            end

            it "returns an error message for itt end date" do
              expect(subject.errors.messages[:itt_end_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.itt_end_date.future")
            end
          end

          context "the end date fields are too far in past" do
            let(:end_date_attributes) do
              { end_day: "12", end_month: "11", end_year: "2001" }
            end

            it "returns an error message for itt end date" do
              expect(subject.errors.messages[:itt_end_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.itt_end_date.too_old")
            end
          end

          context "for a trainee where end date is not required and is not provided" do
            let(:trainee) { build(:trainee, hesa_id: "XXX") }
            let(:end_date_attributes) do
              { end_day: "", end_month: "", end_year: "" }
            end

            it "does not return an error message for end date" do
              expect(subject.errors[:itt_end_date]).to be_empty
            end
          end
        end
      end
    end

    context "study_mode" do
      context "required route" do
        before do
          subject.valid?
        end

        context "study_mode is blank" do
          let(:trainee) { create(:trainee, :provider_led_postgrad, study_mode: nil) }

          it "returns an error" do
            expect(subject.errors[:study_mode]).not_to be_empty
          end
        end

        context "study_mode is set" do
          let(:trainee) { create(:trainee, :provider_led_postgrad, study_mode: COURSE_STUDY_MODES[:full_time]) }

          it "no error" do
            expect(subject.errors[:study_mode]).to be_empty
          end
        end
      end

      context "not required route" do
        let(:trainee) { create(:trainee, :assessment_only, study_mode: nil) }

        before do
          subject.valid?
        end

        context "study_mode is blank" do
          it "no error" do
            expect(subject.errors[:study_mode]).to be_empty
          end
        end
      end
    end

    context "HESA trainee record" do
      let(:trainee) { build(:trainee, hesa_id: "XXX") }

      context "itt_end_date not set" do
        let(:params) { {} }

        before do
          subject.valid?
        end

        it "does not validate itt_end_date" do
          expect(subject.errors[:itt_end_date]).to be_empty
        end

        it "returns nil" do
          expect(subject.itt_end_date).to be_nil
        end
      end

      context "itt_end_date invalid" do
        let(:params) do
          {
            end_day: "a",
            end_month: "b",
            end_year: "c",
          }
        end

        before do
          subject.valid?
        end

        it "validates itt_end_date" do
          expect(subject.errors[:itt_end_date]).not_to be_empty
        end
      end

      context "itt_end_date is set" do
        let(:valid_start_date) do
          Faker::Date.between(from: 1.year.ago, to: 2.days.ago)
        end

        let(:valid_end_date) do
          Faker::Date.between(from: valid_start_date + 1.day, to: Time.zone.today)
        end

        let(:params) do
          {
            start_day: valid_start_date.day.to_s,
            start_month: valid_start_date.month.to_s,
            start_year: valid_start_date.year.to_s,
            end_day: valid_end_date.day.to_s,
            end_month: valid_end_date.month.to_s,
            end_year: valid_end_date.year.to_s,
          }
        end

        before do
          subject.valid?
        end

        it "sets the end date correctly" do
          expect(subject.itt_end_date).to eq(valid_end_date)
        end
      end
    end
  end

  context "valid trainee" do
    let(:valid_start_date) do
      Faker::Date.between(from: 1.year.ago, to: 2.days.ago)
    end

    let(:valid_end_date) do
      Faker::Date.between(from: valid_start_date + 1.day, to: Time.zone.today)
    end

    let(:min_age) { 11 }
    let(:max_age) { 19 }
    let(:primary_course_subjects) { PublishSubjects::PRIMARY_WITH_GEOGRAPHY_AND_HISTORY }

    let(:params) do
      {
        start_day: valid_start_date.day.to_s,
        start_month: valid_start_date.month.to_s,
        start_year: valid_start_date.year.to_s,
        end_day: valid_end_date.day.to_s,
        end_month: valid_end_date.month.to_s,
        end_year: valid_end_date.year.to_s,
        main_age_range: "#{min_age} to #{max_age}",
        course_subject_one: "Psychology",
        course_subject_two: "Chemistry",
        course_subject_three: "Art and design",
        primary_course_subjects: primary_course_subjects,
      }
    end

    let(:trainee) { create(:trainee) }

    describe "#save!" do
      let(:allocation_subject) { create(:subject_specialism, name: params[:course_subject_one]).allocation_subject }

      before do
        allow(form_store).to receive(:set).with(trainee.id, :course_details, nil)
      end

      it "changed related trainee attributes" do
        expect { subject.save! }
          .to change { trainee.course_subject_one }
          .from(nil).to(params[:course_subject_one])
          .and change { trainee.course_min_age }
          .from(nil).to(min_age)
          .and change { trainee.course_max_age }
          .from(nil).to(max_age)
          .and change { trainee.itt_start_date }
          .from(nil).to(Date.parse(valid_start_date.to_s))
          .and change { trainee.itt_end_date }
          .from(nil).to(Date.parse(valid_end_date.to_s))
          .and change { trainee.course_allocation_subject }
          .from(nil).to(allocation_subject)
      end

      context "with primary education phase" do
        let(:trainee) { create(:trainee, :with_primary_education) }
        let(:primary_course_subjects) { PublishSubjects::PRIMARY_WITH_GEOGRAPHY_AND_HISTORY }

        it "adds the course_subjects from the primary_course_subjects" do
          expect { subject.save! }
            .to change { trainee.course_subject_one }
            .from(nil).to(CourseSubjects::PRIMARY_TEACHING)
            .and change { trainee.course_subject_two }
            .from(nil).to(CourseSubjects::GEOGRAPHY)
            .and change { trainee.course_subject_three }
            .from(nil).to(CourseSubjects::HISTORY)
        end

        context 'when "Primary with another subject" is selected' do
          let(:primary_course_subjects) { :other }

          it "adds the course_subjects from the primary_course_subjects" do
            expect { subject.save! }
              .to change { trainee.course_subject_one }
              .from(nil).to(CourseSubjects::PRIMARY_TEACHING)
              .and change { trainee.course_subject_two }
              .from(nil).to("Chemistry")
              .and change { trainee.course_subject_three }
              .from(nil).to("Art and design")
          end
        end
      end

      context "when a trainee has a course uuid" do
        let(:trainee) { create(:trainee, course_uuid: SecureRandom.uuid) }

        before do
          subject.save!
          trainee.reload
        end

        it "doesnt wipe course uuid" do
          expect(trainee.course_uuid).not_to be_nil
        end
      end

      context "when the course_subject has changed" do
        let(:progress) { Progress.new(course_details: true, funding: true, personal_details: true) }
        let(:trainee) do
          create(:trainee,
                 :with_funding,
                 :with_publish_course_details,
                 applying_for_scholarship: true,
                 course_subject_one: CourseSubjects::BIOLOGY,
                 progress: progress)
        end

        let(:params) do
          {
            course_subject_one: CourseSubjects::HISTORICAL_LINGUISTICS,
          }
        end

        before do
          create(:subject_specialism, name: CourseSubjects::HISTORICAL_LINGUISTICS)
        end

        it "nullifies the course_uuid, bursary information and resets funding section progress" do
          expect { subject.save! }
          .to change { trainee.applying_for_bursary }
          .from(trainee.applying_for_bursary).to(nil)
          .and change { trainee.course_uuid }.to(nil)
          .and change { trainee.applying_for_scholarship }.to(nil)
          .and change { trainee.progress.funding }.from(true).to(false)
        end
      end

      context "with a non-draft updating the course details" do
        let(:trainee) { create(:trainee, :with_secondary_course_details, :trn_received) }

        let(:described_instance) { described_class.new(trainee, params: params, store: form_store) }

        subject { described_instance.save! }

        before do
          allow(described_instance).to receive(:course_education_phase).and_return(COURSE_EDUCATION_PHASE_ENUMS[:primary])
        end

        it "updates the course education phase" do
          expect { subject }
            .to change { trainee.course_education_phase }
            .from(trainee.course_education_phase).to(COURSE_EDUCATION_PHASE_ENUMS[:primary])
        end
      end
    end

    describe "#stash" do
      let(:fields) { params.merge({ course_uuid: nil }) }

      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and course_details" do
        expect(form_store).to receive(:set).with(trainee.id, :course_details, fields)

        subject.stash
      end
    end
  end

  describe "#compute_fields" do
    context "non early_years route" do
      let(:trainee) { build(:trainee) }

      it "include course subject columns" do
        expect(subject.send(:compute_fields)).to include(:course_subject_one, :course_subject_two, :course_subject_three)
      end
    end

    context "early_years route" do
      let(:trainee) { build(:trainee, :early_years_undergrad) }

      it "shouldnt include course subject columns" do
        expect(subject.send(:compute_fields)).not_to include(:course_subject_one, :course_subject_two, :course_subject_three)
      end
    end
  end
end

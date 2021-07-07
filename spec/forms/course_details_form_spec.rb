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
        expect(subject.errors[:course_start_date]).to be_empty
        expect(subject.errors[:course_end_date]).to be_empty
      end
    end
  end

  describe "validations" do
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
      translation_key_prefix = "activemodel.errors.models.course_details_form.attributes"

      before do
        subject.assign_attributes(attributes)
        subject.valid?
      end

      describe "#age_range_valid" do
        let(:attributes) do
          { main_age_range: main_age_range }
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
          if attribute_name == :course_start_date
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

        describe "#course_start_date_valid" do
          let(:end_date_attributes) { {} }

          context "the start date fields are 12/11/2020" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2020" }
            end

            it "does not return an error message for course start date" do
              expect(subject.errors[:course_start_date]).to be_empty
            end
          end

          include_examples date_error_message, :course_start_date, :blank,
                           "", "", ""
          include_examples date_error_message, :course_start_date, :invalid,
                           "foo", "foo", "foo"

          start_date = 10.years.ago
          include_examples date_error_message, :course_start_date, :too_old,
                           start_date.day, start_date.month, start_date.year

          context "the start date fields are too far in future" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2099" }
            end

            it "returns an error message for course start date" do
              expect(subject.errors.messages[:course_start_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.course_start_date.future")
            end
          end

          context "the start date fields are too far in past" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2000" }
            end

            it "returns an error message for course start date" do
              expect(subject.errors.messages[:course_start_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.course_start_date.too_old")
            end
          end
        end

        describe "#course_end_date_valid" do
          start_date = 1.month.ago

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
              expect(subject.errors[:course_end_date]).to be_empty
            end
          end

          include_examples date_error_message, :course_end_date, :blank,
                           "", "", ""
          include_examples date_error_message, :course_end_date, :invalid,
                           "foo", "foo", "foo"
          include_examples date_error_message, :course_end_date, :before_or_same_as_start_date,
                           start_date.day, start_date.month, start_date.year
          include_examples date_error_message, :course_end_date, :before_or_same_as_start_date,
                           start_date.day, start_date.month, start_date.year - 1

          context "the end date fields are too far in future" do
            let(:end_date_attributes) do
              { end_day: "12", end_month: "11", end_year: "3000" }
            end

            it "returns an error message for course end date" do
              expect(subject.errors.messages[:course_end_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.course_end_date.future")
            end
          end

          context "the end date fields are too far in past" do
            let(:end_date_attributes) do
              { end_day: "12", end_month: "11", end_year: "2001" }
            end

            it "returns an error message for course end date" do
              expect(subject.errors.messages[:course_end_date]).to include I18n.t("activemodel.errors.models.course_details_form.attributes.course_end_date.too_old")
            end
          end
        end
      end
    end
  end

  context "valid trainee" do
    let(:valid_start_date) do
      Faker::Date.between(from: 10.years.ago, to: 2.days.ago)
    end

    let(:valid_end_date) do
      Faker::Date.between(from: valid_start_date + 1.day, to: Time.zone.today)
    end

    let(:min_age) { 11 }
    let(:max_age) { 19 }

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
      }
    end

    let(:trainee) { create(:trainee) }

    describe "#save!" do
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
          .and change { trainee.course_start_date }
          .from(nil).to(Date.parse(valid_start_date.to_s))
          .and change { trainee.course_end_date }
          .from(nil).to(Date.parse(valid_end_date.to_s))
      end

      context "when a trainee has a course code" do
        let(:trainee) { create(:trainee, course_code: Faker::Alphanumeric.alphanumeric(number: 4).upcase) }

        before do
          subject.save!
          trainee.reload
        end

        it "doesnt wipe course code" do
          expect(trainee.course_code).not_to eq nil
        end
      end

      context "when the course_subject has changed" do
        let(:progress) { Progress.new(course_details: true, funding: true, personal_details: true) }
        let(:trainee) { create(:trainee, :with_funding, :with_course_details, course_subject_one: Dttp::CodeSets::CourseSubjects::BIOLOGY, progress: progress) }
        let(:params) do
          {
            course_subject_one: Dttp::CodeSets::CourseSubjects::HISTORICAL_LINGUISTICS,
          }
        end

        it "nullifies the bursary information and resets funding section progress" do
          expect { subject.save! }
          .to change { trainee.applying_for_bursary }
          .from(trainee.applying_for_bursary).to(nil)
          .and change { trainee.progress.funding }
          .from(true).to(false)
        end
      end
    end

    describe "#stash" do
      let(:fields) { params }

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

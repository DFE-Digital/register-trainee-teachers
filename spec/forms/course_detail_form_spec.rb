# frozen_string_literal: true

require "rails_helper"

describe CourseDetailsForm, type: :model do
  let(:params) { {} }
  let(:trainee) { build(:trainee) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params, form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "before validation" do
    context "#sanitise_course_dates" do
      let(:params) do
        { start_day: "1 2",
          start_month: "1 1",
          start_year: "2 0 2 0",
          end_day: "1 2",
          end_month: "1 1",
          end_year: "2 0 2 1" }
      end

      before do
        subject.sanitise_course_dates
        subject.valid?
      end

      it "does not return course date errors" do
        expect(subject.errors[:course_start_date]).to be_empty
        expect(subject.errors[:course_end_date]).to be_empty
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }

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

        context "main age range is 3 to 11 course" do
          let(:main_age_range) { "3 to 11 course" }
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
              expect(subject.errors[:additional_age_range]).to include(
                I18n.t(
                  "#{translation_key_prefix}.main_age_range.blank",
                ),
              )
            end
          end

          context "additional age range is 0 - 5 course" do
            let(:additional_age_range) { "0 - 5 course" }

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

    let(:params) do
      { start_day: valid_start_date.day.to_s,
        start_month: valid_start_date.month.to_s,
        start_year: valid_start_date.year.to_s,
        end_day: valid_end_date.day.to_s,
        end_month: valid_end_date.month.to_s,
        end_year: valid_end_date.year.to_s,
        main_age_range: "11 to 19 course",
        subject: "Psychology" }
    end

    let(:trainee) { create(:trainee) }

    describe "#save!" do
      before do
        allow(form_store).to receive(:set).with(trainee.id, :course_details, nil)
      end

      it "changed related trainee attributes" do
        expect { subject.save! }
          .to change { trainee.subject }
          .from(nil).to(params[:subject])
          .and change { trainee.age_range }
          .from(nil).to(params[:main_age_range])
          .and change { trainee.course_start_date }
          .from(nil).to(Date.parse(valid_start_date.to_s))
          .and change { trainee.course_end_date }
          .from(nil).to(Date.parse(valid_end_date.to_s))
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
end

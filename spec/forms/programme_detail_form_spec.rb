# frozen_string_literal: true

require "rails_helper"

describe ProgrammeDetailForm, type: :model do
  let(:trainee) { build(:trainee) }

  subject { described_class.new(trainee) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject) }

    describe "custom" do
      translation_key_prefix = "activemodel.errors.models.programme_detail_form.attributes"

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

        context "main age range is 3 to 11 programme" do
          let(:main_age_range) { "3 to 11 programme" }
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

          context "additional age range is 0 - 5 programme" do
            let(:additional_age_range) { "0 - 5 programme" }

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
          if attribute_name == :programme_start_date
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

        describe "#programme_start_date_valid" do
          let(:end_date_attributes) { {} }

          context "the start date fields are 12/11/2020" do
            let(:start_date_attributes) do
              { start_day: "12", start_month: "11", start_year: "2020" }
            end

            it "does not return an error message for programme start date" do
              expect(subject.errors[:programme_start_date]).to be_empty
            end
          end

          include_examples date_error_message, :programme_start_date, :blank,
                           "", "", ""
          include_examples date_error_message, :programme_start_date, :invalid,
                           "foo", "foo", "foo"

          start_date = 10.years.ago
          include_examples date_error_message, :programme_start_date, :over_10_years,
                           start_date.day, start_date.month, start_date.year
        end

        describe "#programme_end_date_valid" do
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
              expect(subject.errors[:programme_end_date]).to be_empty
            end
          end

          include_examples date_error_message, :programme_end_date, :blank,
                           "", "", ""
          include_examples date_error_message, :programme_end_date, :invalid,
                           "foo", "foo", "foo"
          include_examples date_error_message, :programme_end_date, :before_or_same_as_start_date,
                           start_date.day, start_date.month, start_date.year
          include_examples date_error_message, :programme_end_date, :before_or_same_as_start_date,
                           start_date.day, start_date.month, start_date.year - 1
        end
      end
    end

    describe "after_validation callback" do
      describe "update_trainee" do
        before do
          subject.assign_attributes(attributes)
        end

        context "valid attributes" do
          let(:valid_start_date) do
            Faker::Date.between(from: 10.years.ago, to: 2.days.ago)
          end

          let(:valid_end_date) do
            Faker::Date.between(from: valid_start_date + 1.day, to: Time.zone.today)
          end

          let(:attributes) do
            { start_day: valid_start_date.day.to_s,
              start_month: valid_start_date.month.to_s,
              start_year: valid_start_date.year.to_s,
              end_day: valid_end_date.day.to_s,
              end_month: valid_end_date.month.to_s,
              end_year: valid_end_date.year.to_s,
              main_age_range: "11 to 19 programme",
              subject: "Psychology" }
          end

          it "changed related trainee attributes" do
            expect { subject.valid? }
              .to change { trainee.subject }
              .from(nil).to(attributes[:subject])
              .and change { trainee.age_range }
              .from(nil).to(attributes[:main_age_range])
              .and change { trainee.programme_start_date }
              .from(nil).to(Date.parse(valid_start_date.to_s))
              .and change { trainee.programme_end_date }
              .from(nil).to(Date.parse(valid_end_date.to_s))
          end
        end
      end
    end
  end
end

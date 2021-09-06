# frozen_string_literal: true

require "rails_helper"

describe OutcomeDateForm, type: :model do
  let(:trainee) { create(:trainee, :deferred) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    {
      year: trainee.course_start_date.year,
      month: trainee.course_start_date.month,
      day: trainee.course_start_date.day,
      date_string: "other",
    }
  end

  subject { described_class.new(trainee, params: params.stringify_keys, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    context "date" do
      context "empty date" do
        before do
          subject.date_string = nil
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date_string]).to include(
            I18n.t(
              "activemodel.errors.models.outcome_date_form.attributes.date_string.blank",
            ),
          )
        end
      end

      context "invalid date" do
        before do
          subject.month = nil
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date]).to include(
            I18n.t(
              "activemodel.errors.models.outcome_date_form.attributes.date.invalid",
            ),
          )
        end
      end

      context "future date" do
        before do
          subject.year = Time.zone.today.year + 1

          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date]).to include(
            I18n.t(
              "activemodel.errors.models.outcome_date_form.attributes.date.future",
            ),
          )
        end
      end

      include_examples "date is not before course start date", :outcome_date_form
    end
  end

  describe "#fields" do
    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match(params)
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and deferral_details" do
      expect(form_store).to receive(:set).with(trainee.id, :outcome_date, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :outcome_date, nil)

      date_params = params.except("date_string").values.map(&:to_i)
      expect { subject.save! }.to change(trainee, :outcome_date).to(Date.new(*date_params))
    end
  end
end

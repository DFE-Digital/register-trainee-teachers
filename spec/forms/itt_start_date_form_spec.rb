# frozen_string_literal: true

require "rails_helper"

describe IttStartDateForm, type: :model do
  let(:trainee) { create(:trainee, :pg_teaching_apprenticeship) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    date = Faker::Date.between(from: 10.years.ago, to: 2.days.ago)
    {
      year: date.year.to_s,
      month: date.month.to_s,
      day: date.day.to_s,
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
              "activemodel.errors.models.itt_start_date_form.attributes.date_string.blank",
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
              "activemodel.errors.models.itt_start_date_form.attributes.date.invalid",
            ),
          )
        end
      end

      context "future date" do
        before do
          subject.year = "2099"
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date]).to include(
            I18n.t(
              "activemodel.errors.models.itt_start_date_form.attributes.date.future",
            ),
          )
        end
      end

      context "too old date" do
        before do
          subject.day = "12"
          subject.month = "11"
          subject.year = "2000"
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:date]).to include(
            I18n.t(
              "activemodel.errors.models.itt_start_date_form.attributes.date.too_old",
            ),
          )
        end
      end
    end
  end

  describe "#fields" do
    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match(params)
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and itt start date" do
      expect(form_store).to receive(:set).with(trainee.id, :itt_start_date, subject.fields)

      subject.stash
    end
  end
end

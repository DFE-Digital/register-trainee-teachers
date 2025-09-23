# frozen_string_literal: true

require "rails_helper"

describe OutcomeDateForm, type: :model do
  include ActiveJob::TestHelper

  let(:trainee) { create(:trainee, :deferred) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    {
      year: trainee.itt_start_date.year,
      month: trainee.itt_start_date.month,
      day: trainee.itt_start_date.day,
      date_string: "other",
    }
  end

  let(:outcome_date_form) do
    described_class.new(trainee, params: params.stringify_keys, store: form_store)
  end

  subject { outcome_date_form }

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

      it_behaves_like "date is not before itt start date", :outcome_date_form
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
    before { enable_features(:integrate_with_dqt) }

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :outcome_date, nil)

      date_params = params.except("date_string").values.map(&:to_i)
      expect { subject.save! }.to change(trainee.reload, :outcome_date).to(Date.new(*date_params))
    end

    it "calls update trainee on DQT API" do
      expect(form_store).to receive(:set).with(trainee.id, :outcome_date, nil)

      expect(outcome_date_form).to be_valid
    end

    context "when we opt-out of DQT API call" do
      subject do
        described_class.new(
          trainee,
          params: params.stringify_keys,
          store: form_store,
          update_dqt: false,
        )
      end

      it "skips update trainee on DQT API" do
        expect(form_store).to receive(:set).with(trainee.id, :outcome_date, nil)
      end
    end
  end
end

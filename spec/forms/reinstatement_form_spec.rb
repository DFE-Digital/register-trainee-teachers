# frozen_string_literal: true

require "rails_helper"

describe ReinstatementForm, type: :model do
  let(:trainee) { create(:trainee, :reinstated) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    {
      year: trainee.itt_start_date.year,
      month: trainee.itt_start_date.month,
      day: trainee.itt_start_date.day,
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
              "activemodel.errors.models.reinstatement_form.attributes.date_string.blank",
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
              "activemodel.errors.models.reinstatement_form.attributes.date.invalid",
            ),
          )
        end
      end

      include_examples "date is not before itt start date", :reinstatement_form
    end
  end

  describe "#fields" do
    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match(params)
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and deferral_details" do
      expect(form_store).to receive(:set).with(trainee.id, :reinstatement, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:expected_date_params) { params.except("date_string").values.map(&:to_i) }

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :reinstatement, nil)

      expect { subject.save! }.to change(trainee, :reinstate_date).to(Date.new(*expected_date_params))
    end

    context "itt start date is in the future" do
      let(:trainee) do
        create(:trainee, :deferred, commencement_date: nil, itt_start_date: Time.zone.today + 1.day)
      end

      before do
        allow(form_store).to receive(:set).with(trainee.id, :reinstatement, nil)
      end

      it "saves the reinstatement date as the commencement date" do
        expect { subject.save! }.to change(trainee, :commencement_date).to(Date.new(*expected_date_params))
      end
    end
  end
end

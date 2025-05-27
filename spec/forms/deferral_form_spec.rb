# frozen_string_literal: true

require "rails_helper"

describe DeferralForm, type: :model do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:form_store) { class_double(FormStore) }

  let(:params) do
    {
      year: trainee.itt_start_date.year,
      month: trainee.itt_start_date.month,
      day: trainee.itt_start_date.day,
      date_string: "other",
      defer_reason: "just not ready",
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
              "activemodel.errors.models.deferral_form.attributes.date_string.blank",
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
              "activemodel.errors.models.deferral_form.attributes.date.invalid",
            ),
          )
        end
      end

      context "when itt start date is in the future" do
        let(:trainee) { create(:trainee, itt_start_date: 10.days.from_now) }

        let(:params) do
          {}
        end

        before do
          subject.validate
        end

        it "is valid" do
          expect(subject.errors).to be_empty
        end
      end

      context "when itt start date is in the past, but the trainee has not started" do
        let(:trainee) { create(:trainee, itt_start_date: 1.day.ago, commencement_status: :itt_not_yet_started) }

        let(:params) do
          {}
        end

        before do
          subject.validate
        end

        it "is valid" do
          expect(subject.errors).to be_empty
        end
      end

      it_behaves_like "date is not before itt start date", :deferral_form
    end
  end

  describe "#fields" do
    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match(params)
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and deferral_details" do
      expect(form_store).to receive(:set).with(trainee.id, :deferral, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:params) do
      {
        year: trainee.itt_start_date.year + 1,
        month: trainee.itt_start_date.month,
        day: trainee.itt_start_date.day,
        date_string: "other",
      }
    end

    before do
      allow(FormStore).to receive(:get)
      allow(form_store).to receive(:set).with(trainee.id, :deferral, nil)
    end

    it "transitions the trainee state to deferred" do
      expect { subject.save! }.to change(trainee, :state).to("deferred")
    end

    it "takes any data from the form store and saves it to the database and clears the store data" do
      date_params = params.except("date_string").values.map(&:to_i)
      expect { subject.save! }.to change(trainee, :defer_date).to(Date.new(*date_params))
    end

    context "when start date is changed" do
      let(:trainee) { create(:trainee, :deferred, trainee_start_date: nil) }

      before do
        allow(FormStore).to receive(:get).with(trainee.id, :trainee_start_status).and_return({
          "day" => "21",
          "month" => "9",
          "year" => "2021",
        })
      end

      it "takes any data from the form store and saves it to the database and clears the store data" do
        expect(form_store).to receive(:set).with(trainee.id, :deferral, nil)
        expect(FormStore).to receive(:set).with(trainee.id, :trainee_start_status, nil)
        expect(FormStore).to receive(:set).with(trainee.id, :start_date_verification, nil)

        expect { subject.save! }.to change(trainee, :trainee_start_date).to(Date.parse("21-9-2021"))
      end
    end
  end
end

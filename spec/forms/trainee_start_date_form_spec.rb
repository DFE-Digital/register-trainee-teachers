# frozen_string_literal: true

require "rails_helper"

describe TraineeStartDateForm, type: :model do
  let(:params) { { year: "2020", month: "12", day: "20" } }
  let(:trainee) { build(:trainee, :not_started) }
  let(:form_store) { class_double(FormStore) }
  let(:error_attr) { "activemodel.errors.models.training_details_form.attributes.commencement_date" }

  subject { described_class.new(trainee, params, form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    subject { described_class.new(trainee, params) }

    before { subject.validate }

    context "invalid date" do
      let(:params) { { day: 20, month: 20, year: 2020 } }

      it "is invalid" do
        expect(subject.errors[:commencement_date]).to include(I18n.t("#{error_attr}.invalid"))
      end
    end

    context "blank date" do
      let(:params) { { day: "", month: "", year: "" } }

      it "is invalid" do
        expect(subject.errors[:commencement_date]).to include(I18n.t("#{error_attr}.blank"))
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and trainee_id" do
      expect(form_store).to receive(:set).with(trainee.id, :trainee_start_date, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:trainee) { create(:trainee) }

    before do
      allow(form_store).to receive(:set).with(trainee.id, :trainee_start_date, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      date_params = params.values.map(&:to_i)
      expect { subject.save! }.to change(trainee, :commencement_date).to(Date.new(*date_params))
    end
  end
end

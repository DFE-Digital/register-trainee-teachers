# frozen_string_literal: true

require "rails_helper"

describe IttEndDateForm, type: :model do
  let(:params) { valid_date }
  let(:valid_date) { { year: "2020", month: "12", day: "20" } }
  let(:trainee) { build(:trainee, :incomplete) }
  let(:form_store) { class_double(FormStore) }
  let(:reinstatement_form) { class_double(ReinstatementForm) }
  let(:error_attr) { "activemodel.errors.models.itt_end_date_form.attributes.itt_end_date" }
  let(:itt_end_date_form) { described_class.new(trainee, params: params, store: form_store) }
  let(:return_date) { Date.parse(valid_date.values.join("/")) - 1.day }

  subject { itt_end_date_form }

  before do
    allow(form_store).to receive(:get).and_return(nil)
    allow(itt_end_date_form).to receive(:return_date).and_return(return_date)
  end

  describe "validations" do
    before { subject.validate }

    context "invalid date" do
      let(:params) { { day: 20, month: 20, year: 2020 } }

      it "is invalid" do
        expect(subject.errors[:itt_end_date]).to include(I18n.t("#{error_attr}.invalid"))
      end
    end

    context "blank date" do
      let(:params) { { day: "", month: "", year: "" } }

      it "is invalid" do
        expect(subject.errors[:itt_end_date]).to include(I18n.t("#{error_attr}.blank"))
      end
    end

    context "date earlier then the return date" do
      let(:params) { { year: "2009", month: "12", day: "20" } }
      let(:return_date) { Date.parse(params.values.join("/")) + 1.day }

      it "is invalid" do
        expect(subject.errors[:itt_end_date]).to include(I18n.t("#{error_attr}.return_date"))
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and trainee_id" do
      expect(form_store).to receive(:set).with(trainee.id, :itt_end_date, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:trainee) { create(:trainee, itt_start_date: Time.zone.today) }

    before do
      allow(form_store).to receive(:set).with(trainee.id, :itt_end_date, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      date_params = params.values.map(&:to_i)
      expect { subject.save! }.to change(trainee, :itt_end_date).to(Date.new(*date_params))
    end
  end
end

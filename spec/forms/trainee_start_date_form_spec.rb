# frozen_string_literal: true

require "rails_helper"

describe TraineeStartDateForm, type: :model do
  let(:params) { { year: "2020", month: "12", day: "20" } }
  let(:trainee) { build(:trainee, :incomplete) }
  let(:form_store) { class_double(FormStore) }
  let(:error_attr) { "activemodel.errors.models.trainee_start_date_form.attributes.trainee_start_date" }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    before { subject.validate }

    context "invalid date" do
      let(:params) { { day: 20, month: 20, year: 2020 } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.invalid"))
      end
    end

    context "blank date" do
      let(:params) { { day: "", month: "", year: "" } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.blank"))
      end
    end

    context "date is after the itt end date" do
      let(:trainee) do
        build(:trainee, itt_end_date: Date.parse("19/12/2020"))
      end

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(
          I18n.t(
            "#{error_attr}.not_after_itt_end_date_html",
            itt_end_date: trainee.itt_end_date.strftime("%-d %B %Y"),
          ),
        )
      end
    end

    it_behaves_like "start date validations"

    context "date is more than 10 years in the past" do
      let(:params) { { year: "2009", month: "12", day: "20" } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.too_old"))
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
    let(:trainee) { create(:trainee, itt_start_date: Time.zone.today) }

    before do
      allow(form_store).to receive(:set).with(trainee.id, :trainee_start_date, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      date_params = params.values.map(&:to_i)
      expect { subject.save! }.to change(trainee, :trainee_start_date).to(Date.new(*date_params))
    end
  end
end

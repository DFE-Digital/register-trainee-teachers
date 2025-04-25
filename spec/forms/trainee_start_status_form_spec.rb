# frozen_string_literal: true

require "rails_helper"

describe TraineeStartStatusForm, type: :model do
  let(:params) { { year: "2020", month: "12", day: "20", commencement_status: "itt_started_later" } }
  let(:trainee) { build(:trainee, :incomplete) }
  let(:form_store) { class_double(FormStore) }
  let(:error_attr) { "activemodel.errors.models.trainee_start_status_form.attributes.trainee_start_date" }

  subject { described_class.new(trainee, params: params, store: form_store) }

  before do
    allow(form_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    before { subject.validate }

    context "without a commencement_status" do
      let(:params) { {} }
      let(:error_attr) { "activemodel.errors.models.trainee_start_status_form.attributes.commencement_status" }

      it "is invalid" do
        expect(subject.errors[:commencement_status]).to include(I18n.t("#{error_attr}.blank"))
      end
    end

    context "invalid date" do
      let(:params) { { day: 20, month: 20, year: 2020, commencement_status: "itt_started_later" } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.invalid"))
      end
    end

    context "blank date" do
      let(:params) { { day: "", month: "", year: "", commencement_status: "itt_started_later" } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.blank"))
      end

      context "when trainee started on time" do
        let(:params) { { day: "", month: "", year: "", commencement_status: "itt_started_on_time" } }

        let(:trainee) { build(:trainee, itt_start_date: Time.zone.today) }

        it "uses the trainee's itt_start_date" do
          expect(subject.trainee_start_date).to eq(trainee.itt_start_date)
        end

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "when trainee did not start yet" do
        let(:params) { { day: "20", month: "12", year: "2020", commencement_status: "itt_not_yet_started" } }

        it "unsets the trainee's trainee_start_date" do
          expect(subject.trainee_start_date).to have_attributes(year: nil, month: nil, day: nil)
        end

        it "is valid" do
          expect(subject).to be_valid
        end
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
      let(:params) { { year: "2009", month: "12", day: "20", commencement_status: "itt_started_later" } }

      it "is invalid" do
        expect(subject.errors[:trainee_start_date]).to include(I18n.t("#{error_attr}.too_old"))
      end
    end
  end

  describe "#stash" do
    let(:trainee) { create(:trainee) }

    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and trainee_id" do
      expect(form_store).to receive(:set).with(trainee.id, :trainee_start_status, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    let(:trainee) { create(:trainee) }

    before do
      allow(form_store).to receive(:set).with(trainee.id, :trainee_start_status, nil)
    end

    it "takes any data from the form store and saves it to the database" do
      date_params = params.values.map(&:to_i)
      expect {
        subject.save!
      }.to change(trainee, :trainee_start_date).to(Date.new(*date_params))
      .and change(trainee, :commencement_status).to("itt_started_later")
    end
  end
end

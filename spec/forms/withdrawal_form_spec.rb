# frozen_string_literal: true

require "rails_helper"

describe WithdrawalForm, type: :model do
  let(:params) { {} }
  let(:trainee) { create(:trainee, :withdrawn, :withdrawn_for_another_reason) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, params: params, store: form_store) }

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
              "activemodel.errors.models.withdrawal_form.attributes.date_string.blank",
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
              "activemodel.errors.models.withdrawal_form.attributes.date.invalid",
            ),
          )
        end
      end
    end
  end

  describe "#fields" do
    let(:params) do
      {
        "day" => "11",
        "month" => "11",
        "year" => "1963",
        "date_string" => "other",
        "withdraw_reason" => WithdrawalReasons::HEALTH_REASONS,
        "additional_withdraw_reason" => "",
      }
    end

    it "combines the data from params with the existing trainee data" do
      expect(subject.fields).to match({
        date_string: "other",
        day: "11",
        month: "11",
        year: "1963",
        withdraw_reason: WithdrawalReasons::HEALTH_REASONS,
        additional_withdraw_reason: "",
      })
    end
  end

  describe "#stash" do
    it "uses FormStore to temporarily save the fields under a key combination of trainee ID and deferral_details" do
      expect(form_store).to receive(:set).with(trainee.id, :withdrawal, subject.fields)

      subject.stash
    end
  end

  describe "#save!" do
    before do
      allow(form_store).to receive(:get).and_return({
        "withdraw_reason" => WithdrawalReasons::FINANCIAL_REASONS,
      })
    end

    it "takes any data from the form store and saves it to the database and clears the store data" do
      expect(form_store).to receive(:set).with(trainee.id, :withdrawal, nil)

      expect { subject.save! }.to change(trainee, :withdraw_reason).to(WithdrawalReasons::FINANCIAL_REASONS)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Withdrawal::View do
  include SummaryHelper

  let(:trainee) { build(:trainee, withdraw_date: 2.days.ago, trainee_start_date: 3.days.ago, id: 1) }
  let(:withdraw_date) { trainee.withdraw_date }
  let(:withdraw_reason) { WithdrawalReasons::REASONS.sample }
  let(:additional_withdraw_reason) { nil }

  let(:data_model) do
    OpenStruct.new(trainee: trainee, trainee_start_date: trainee.trainee_start_date, date: withdraw_date, withdraw_reason: withdraw_reason, additional_withdraw_reason: additional_withdraw_reason)
  end

  before do
    render_inline(described_class.new(data_model))
  end

  context "withdrawn on another day" do
    it "renders trainee start date" do
      expect(rendered_component).to have_text(date_for_summary_view(trainee.trainee_start_date))
    end

    it "renders the date of withdrawal" do
      expect(rendered_component).to have_text(date_for_summary_view(data_model.date))
    end
  end

  context "withdrawn for a specific reason" do
    let(:withdraw_reason) { WithdrawalReasons::SPECIFIC.sample }

    it "renders the reason for withdrawal" do
      expect(rendered_component).to have_text(I18n.t("components.confirmation.withdrawal_details.reasons.#{data_model.withdraw_reason}"))
    end
  end

  context "for another reason" do
    let(:withdraw_reason) { WithdrawalReasons::FOR_ANOTHER_REASON }
    let(:additional_withdraw_reason) { "some other reason" }

    it "renders the reason for withdrawal" do
      expect(rendered_component).to have_text(data_model.additional_withdraw_reason)
    end
  end

  context "when a deferral date is present" do
    let(:trainee) { build(:trainee, :deferred, id: 1) }

    before do
      render_inline(described_class.new(data_model))
    end

    it "renders the deferral date text" do
      expect(rendered_component).to have_text(
        I18n.t("components.confirmation.withdrawal_details.withdrawal_date", date: date_for_summary_view(withdraw_date)),
      )
    end

    it "suppress the change link" do
      expect(page.find(".date-of-withdrawal")).not_to have_link(t(:change))
    end
  end
end

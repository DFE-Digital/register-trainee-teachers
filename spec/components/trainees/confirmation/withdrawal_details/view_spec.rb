# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::WithdrawalDetails::View do
  include SummaryHelper

  alias_method :component, :page

  let(:trainee) { build(:trainee, :withdrawn_on_another_day, id: 1) }
  let(:withdraw_date) { trainee.withdraw_date }
  let(:withdraw_reason) { nil }
  let(:additional_withdraw_reason) { nil }

  let(:data_model) do
    OpenStruct.new(trainee: trainee, date: withdraw_date, withdraw_reason: withdraw_reason, additional_withdraw_reason: additional_withdraw_reason)
  end

  before do
    render_inline(described_class.new(data_model))
  end

  context "withdrawn on another day" do
    it "renders the date of withdrawal" do
      expect(component).to have_text(date_for_summary_view(data_model.date))
    end
  end

  context "withdrawn for a specific reason" do
    let(:withdraw_reason) { WithdrawalReasons::SPECIFIC.sample }

    it "renders the reason for withdrawal " do
      expect(component).to have_text(I18n.t("components.confirmation.withdrawal_details.reasons.#{data_model.withdraw_reason}"))
    end
  end

  context "for another reason" do
    let(:withdraw_reason) { WithdrawalReasons::FOR_ANOTHER_REASON }
    let(:additional_withdraw_reason) { "some other reason" }

    it "renders the reason for withdrawal " do
      expect(component).to have_text(data_model.additional_withdraw_reason)
    end
  end
end

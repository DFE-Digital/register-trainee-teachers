# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::WithdrawalDetails::View do
  include SummaryHelper

  alias_method :component, :page

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  context "withdrawn on another day" do
    let(:trainee) { build(:trainee, :withdrawn_on_another_day, id: 1) }

    it "renders the date of withdrawal" do
      expect(component).to have_text(date_for_summary_view(trainee.withdraw_date))
    end
  end

  context "withdrawn for a specific reason" do
    let(:trainee) { build(:trainee, :withdrawn_for_specific_reason, id: 1) }

    it "renders the reason for withdrawal " do
      expect(component).to have_text(I18n.t("components.confirmation.withdrawal_details.reasons.#{trainee.withdraw_reason}"))
    end
  end

  context "for another reason" do
    let(:trainee) { build(:trainee, :withdrawn_for_another_reason, id: 1) }

    it "renders the reason for withdrawal " do
      expect(component).to have_text(trainee.additional_withdraw_reason)
    end
  end
end

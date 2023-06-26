# frozen_string_literal: true

require "rails_helper"

describe Withdrawal::View do
  include SummaryHelper

  let!(:trainee) { create(:trainee, :withdrawn_for_specific_reason, withdraw_date: 2.days.ago, trainee_start_date: 3.days.ago) }
  let(:withdraw_date) { trainee.withdraw_date }
  let(:withdrawal_reasons) { trainee.withdrawal_reasons }
  let(:withdraw_reasons_details) { "not enough coffee" }
  let(:withdraw_reasons_dfe_details) { "could provide unlimited coffee" }

  let(:data_model) do
    OpenStruct.new(
      trainee: trainee,
      itt_start_date: trainee.trainee_start_date,
      withdraw_date: withdraw_date,
      withdrawal_reasons: withdrawal_reasons,
      withdraw_reasons_details: withdraw_reasons_details,
      withdraw_reasons_dfe_details: withdraw_reasons_dfe_details,
    )
  end

  before do
    render_inline(described_class.new(data_model:))
  end

  context "when showing a withdrawal" do
    it "renders trainee start date" do
      expect(rendered_component).to have_text(date_for_summary_view(trainee.trainee_start_date))
    end

    it "renders the date of withdrawal" do
      expect(rendered_component).to have_text(date_for_summary_view(withdraw_date))
    end

    it "renders the withdrawal details" do
      expect(rendered_component).to have_text(withdraw_reasons_details)
    end

    it "renders the withdrawal dfe details" do
      expect(rendered_component).to have_text(withdraw_reasons_dfe_details)
    end

    it "renders the reason for withdrawal" do
      expect(rendered_component).to have_text(I18n.t("components.withdrawal_details.reasons.#{withdrawal_reasons.first.name}"))
    end
  end
end

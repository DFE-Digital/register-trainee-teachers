# frozen_string_literal: true

require "rails_helper"

describe Withdrawal::View do
  include SummaryHelper

  let!(:trainee) { create(:trainee, :withdrawn_for_specific_reason, withdraw_date: 2.days.ago, trainee_start_date: 3.days.ago) }
  let(:trainee_withdrawal) { trainee.current_withdrawal }
  let(:withdraw_date) { trainee.withdraw_date }
  let(:withdrawal_reasons) { trainee.withdrawal_reasons }

  let(:data_model) do
    OpenStruct.new(
      trainee: trainee,
      trainee_start_date: trainee.trainee_start_date,
      withdraw_date: withdraw_date,
      withdrawal_reasons: withdrawal_reasons,
      trigger: trainee_withdrawal.trigger,
      future_interest: trainee_withdrawal.future_interest,
    )
  end

  before do
    render_inline(described_class.new(data_model:))
  end

  context "when showing a withdrawal" do
    it "renders trainee start date" do
      expect(rendered_content).to have_text(date_for_summary_view(trainee.trainee_start_date))
    end

    it "renders the date of withdrawal" do
      expect(rendered_content).to have_text(date_for_summary_view(withdraw_date))
    end

    it "renders the reasons for withdrawal" do
      withdrawal_reasons.each do |withdrawal_reason|
        expect(rendered_content).to have_text(I18n.t("components.withdrawal_details.reasons.#{withdrawal_reason.name}"))
      end
    end

    it "renders the trigger for withdrawal" do
      expect(rendered_content).to have_text(I18n.t("views.forms.withdrawal_trigger.#{trainee_withdrawal.trigger}.label"))
    end

    it "renders the candidates' future interest in teaching" do
      expect(rendered_content).to have_text(I18n.t("views.forms.withdrawal_future_interest.#{trainee_withdrawal.future_interest}.label"))
    end

    context "with no withdrawal date present" do
      let(:withdraw_date) { nil }

      it "renders no date of withdrawal" do
        expect(rendered_content).to have_css("#date-the-trainee-withdrew", text: "-")
      end
    end
  end
end

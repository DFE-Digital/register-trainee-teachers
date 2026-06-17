# frozen_string_literal: true

require "rails_helper"

describe FindBulkRecommendTrainees do
  subject(:trainees) { described_class.call }

  let(:itt_end_date) { Time.zone.today }

  context "when the trainee is trn_received with an eligible ITT end date" do
    context "on provider_led_postgrad without placements" do
      let!(:trainee) { create(:trainee, :bulk_recommend, :provider_led_postgrad, :without_placements, itt_end_date:) }

      it { is_expected.not_to include(trainee) }
    end

    context "on provider_led_postgrad with two placements" do
      let!(:trainee) { create(:trainee, :bulk_recommend, :provider_led_postgrad, :with_placements, itt_end_date:) }

      it { is_expected.to include(trainee) }
    end

    context "on school_direct_salaried with one placement" do
      let!(:trainee) do
        create(:trainee, :bulk_recommend, :school_direct_salaried, :with_manual_placements, number_of_placements: 1, itt_end_date: itt_end_date)
      end

      it { is_expected.not_to include(trainee) }
    end

    context "on school_direct_salaried with two placements" do
      let!(:trainee) do
        create(:trainee, :bulk_recommend, :school_direct_salaried, :with_manual_placements, number_of_placements: 2, itt_end_date: itt_end_date)
      end

      it { is_expected.to include(trainee) }
    end

    context "on iqts without placements" do
      let!(:trainee) { create(:trainee, :bulk_recommend, :iqts, :without_placements, itt_end_date:) }

      it { is_expected.not_to include(trainee) }
    end

    context "on iqts with one placement" do
      let!(:trainee) do
        create(:trainee, :bulk_recommend, :iqts, :with_manual_placements, number_of_placements: 1, itt_end_date: itt_end_date)
      end

      it { is_expected.to include(trainee) }
    end

    context "on early_years_postgrad without placements" do
      let!(:trainee) { create(:trainee, :bulk_recommend, :early_years_postgrad, :without_placements, itt_end_date:) }

      it { is_expected.to include(trainee) }
    end

    context "on assessment_only without placements" do
      let!(:trainee) { create(:trainee, :bulk_recommend, :without_placements, itt_end_date:) }

      it { is_expected.to include(trainee) }
    end
  end

  context "when the trainee is outside the ITT end date window" do
    let!(:trainee) do
      create(:trainee, :bulk_recommend, :provider_led_postgrad, :with_placements, itt_end_date: Time.zone.today - 7.months)
    end

    it { is_expected.not_to include(trainee) }
  end
end

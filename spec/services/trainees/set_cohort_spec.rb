# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetCohort do
    let(:current_academic_cycle) { create(:academic_cycle, :current) }

    subject { described_class.call(trainee: trainee).cohort }

    context "when a trainee starts in the current academic cycle" do
      let(:trainee) do
        build(
          :trainee,
          itt_start_date: current_academic_cycle.start_date + 1.week,
          itt_end_date: current_academic_cycle.start_date + 1.year,
        )
      end

      it { is_expected.to eq("current") }
    end

    context "when a trainee starts after the start of the next academic cycle" do
      let(:trainee) do
        build(
          :trainee,
          itt_start_date: current_academic_cycle.end_date + 1.week,
          itt_end_date: current_academic_cycle.end_date + 1.year,
        )
      end

      it { is_expected.to eq("future") }
    end

    context "when a trainee starts before the current academic cycle" do
      context "and is awarded before the start of the current cycle" do
        let(:trainee) do
          build(
            :trainee,
            :awarded,
            awarded_at: current_academic_cycle.start_date - 1.week,
            itt_start_date: current_academic_cycle.start_date - 1.year,
            itt_end_date: current_academic_cycle.start_date - 1.week,
          )
        end

        it { is_expected.to eq("past") }
      end

      context "and is withdrawn before the start of the current cycle" do
        let(:trainee) do
          build(
            :trainee,
            :withdrawn,
            withdraw_date: current_academic_cycle.start_date - 1.week,
            itt_start_date: current_academic_cycle.start_date - 1.year,
            itt_end_date: current_academic_cycle.start_date - 1.week,
          )
        end

        it { is_expected.to eq("past") }
      end

      context "and is deferred before the start of the current cycle" do
        let(:trainee) do
          build(
            :trainee,
            :deferred,
            defer_date: current_academic_cycle.start_date - 1.week,
            itt_start_date: current_academic_cycle.start_date - 1.year,
            itt_end_date: current_academic_cycle.start_date - 1.week,
          )
        end

        it { is_expected.to eq("current") }
      end

      context "when a trainee has no ITT start date" do
        let(:trainee) do
          build(
            :trainee,
            itt_start_date: nil,
            itt_end_date: nil,
          )
        end

        it { is_expected.to eq("current") }
      end
    end
  end
end

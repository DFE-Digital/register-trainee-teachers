# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetAcademicCycles do
    let!(:previous_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let!(:current_academic_cycle) { create(:academic_cycle, :current) }

    describe "start_academic_cycle" do
      subject { described_class.call(trainee: trainee).start_academic_cycle }

      context "when a trainee has a commencement_date" do
        let(:trainee) do
          build(
            :trainee,
            commencement_date: current_academic_cycle.start_date,
            itt_start_date: previous_academic_cycle.start_date,
          )
        end
  
        it "favours commencement_date" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has no commencement_date, but has an itt_start_date" do
        let(:trainee) do
          build(
            :trainee,
            commencement_date: nil,
            itt_start_date: previous_academic_cycle.start_date,
          )
        end
  
        it "favours itt_start_date" do
          expect(subject).to eq(previous_academic_cycle)
        end
      end

      context "when a trainee has no commencement_date/itt_start_date" do
        let(:trainee) { build(:trainee) }
  
        it "favours current academic cycle" do
          expect(subject).to eq(current_academic_cycle)
        end
      end
    end

    describe "end_academic_cycle" do
      subject { described_class.call(trainee: trainee).end_academic_cycle }

      context "when a trainee has an awarded_at" do
        let(:trainee) do
          build(
            :trainee,
            awarded_at: current_academic_cycle.end_date,
            itt_end_date: previous_academic_cycle.end_date,
          )
        end
  
        it "favours awarded_at" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has a withdraw_date" do
        let(:trainee) do
          build(
            :trainee,
            withdraw_date: current_academic_cycle.end_date,
            itt_end_date: previous_academic_cycle.end_date,
          )
        end
  
        it "favours withdraw_date" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has no awarded_at/withdraw_date, but has an itt_end_date" do
        let(:trainee) do
          build(:trainee, itt_end_date: previous_academic_cycle.start_date)
        end
  
        it "favours itt_end_date" do
          expect(subject).to eq(previous_academic_cycle)
        end
      end
    end
  end
end

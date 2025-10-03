# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SetAcademicCycles do
    let!(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }
    let!(:current_academic_cycle) { create(:academic_cycle, :current) }
    let!(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let!(:one_after_next_academic_cycle) { create(:academic_cycle, one_after_next_cycle: true) }

    describe "start_academic_cycle" do
      subject { described_class.call(trainee:).start_academic_cycle }

      context "when a trainee has a trainee_start_date" do
        let(:trainee) do
          build(
            :trainee,
            trainee_start_date: current_academic_cycle.start_date,
            itt_start_date: next_academic_cycle.start_date,
          )
        end

        it "favours trainee_start_date" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has no trainee_start_date, but has an itt_start_date" do
        let(:trainee) do
          build(
            :trainee,
            trainee_start_date: nil,
            itt_start_date: next_academic_cycle.start_date,
          )
        end

        it "favours itt_start_date" do
          expect(subject).to eq(next_academic_cycle)
        end
      end

      context "when a trainee has no trainee_start_date/itt_start_date and we are 3 months from the new cycle" do
        let(:trainee) { build(:trainee) }

        it "favours current academic cycle" do
          Timecop.freeze(next_academic_cycle.start_date - 3.months) do
            expect(subject).to eq(current_academic_cycle)
          end
        end
      end

      context "when a trainee has no trainee_start_date/itt_start_date and we are 3 weeks from the new cycle" do
        let(:trainee) { build(:trainee) }

        it "favours next academic cycle" do
          Timecop.freeze(next_academic_cycle.start_date - 3.weeks) do
            expect(subject).to eq(next_academic_cycle)
          end
        end
      end
    end

    describe "end_academic_cycle" do
      subject { described_class.call(trainee:).end_academic_cycle }

      context "when a trainee has an awarded_at" do
        let(:trainee) do
          build(
            :trainee,
            awarded_at: current_academic_cycle.end_date,
            itt_end_date: next_academic_cycle.end_date,
          )
        end

        it "favours awarded_at" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has a withdraw_date" do
        let(:trainee) do
          create(
            :trainee,
            trainee_withdrawals: [create(:trainee_withdrawal, date: current_academic_cycle.end_date)],
            itt_end_date: next_academic_cycle.end_date,
          )
        end

        it "favours withdraw_date" do
          expect(subject).to eq(current_academic_cycle)
        end
      end

      context "when a trainee has no awarded_at/withdraw_date, but has an itt_end_date" do
        let(:trainee) do
          build(:trainee, itt_end_date: next_academic_cycle.start_date)
        end

        it "favours itt_end_date" do
          expect(subject).to eq(next_academic_cycle)
        end
      end

      context "when a trainee has no awarded_at/withdraw_date/itt_end_date but has a itt_start_date" do
        let(:trainee) do
          build(
            :trainee,
            itt_start_date: current_academic_cycle.start_date,
            hesa_metadatum: hesa_metadatum,
          )
        end

        context "and duration in years" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 1, study_length_unit: "years")
          end

          it "calculates the end academic cycle" do
            expect(subject).to eq(current_academic_cycle)
          end
        end

        context "and duration in months" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 6, study_length_unit: "months")
          end

          it "calculates the end academic cycle" do
            expect(subject).to eq(current_academic_cycle)
          end
        end

        context "and duration in days" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 370, study_length_unit: "days")
          end

          it "calculates the end academic cycle" do
            expect(subject).to eq(next_academic_cycle)
          end
        end

        context "and duration in hours" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 20, study_length_unit: "hours")
          end

          it "calculates the end academic cycle" do
            expect(subject).to eq(current_academic_cycle)
          end
        end

        context "and duration that is longer than 8 years" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 9, study_length_unit: "years")
          end

          it "raises an exception" do
            msg = "Trainee id: #{trainee.id}, slug: #{trainee.slug} has a course length greater than eight years"
            expect { subject }.to raise_error(msg)
          end
        end

        context "and duration that is invalid" do
          let(:hesa_metadatum) do
            build(:hesa_metadatum, study_length: 2, study_length_unit: "rainbows")
          end

          it "defaults to estimated course duration based on route/studymode" do
            expect(subject).to eq(next_academic_cycle)
          end
        end
      end

      context "when a trainee has no awarded_at/withdraw_date/itt_end_date/start_date" do
        let(:trainee) { build(:trainee) }

        it "does not set the end academic cycle" do
          expect(subject).to be_nil
        end
      end

      context "when a trainee has no awarded_at/withdraw_date/itt_end_date/course duration" do
        let(:training_route) { :provider_led_postgrad }
        let(:study_mode) { :full_time }
        let(:trainee) do
          build(
            :trainee,
            training_route,
            study_mode: study_mode,
            itt_start_date: previous_academic_cycle.start_date,
          )
        end

        context "and is on an undergrad route" do
          let(:training_route) { :provider_led_undergrad }

          it "calculates end academic cycle with a duration of 3 years" do
            expect(subject).to eq(one_after_next_academic_cycle)
          end
        end

        context "and is part time" do
          let(:study_mode) { :part_time }

          it "calculates end academic cycle with a duration of 2 years" do
            expect(subject).to eq(next_academic_cycle)
          end
        end

        context "and is on a full-time postgrad route" do
          it "calculates end academic cycle with a duration of 1 year" do
            expect(subject).to eq(current_academic_cycle)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Reports
  describe ClaimsDegreesForm do
    describe "validations" do
      context "with valid date components within 1 year" do
        let!(:trainee) { create(:trainee, :trn_received) }
        let!(:degree) { create(:degree, trainee: trainee, created_at: Date.new(2023, 8, 1)) }

        subject { described_class.new(from_day: "1", from_month: "6", from_year: "2023", to_day: "31", to_month: "12", to_year: "2023") }

        it { is_expected.to be_valid }
      end

      context "with missing from date" do
        subject { described_class.new(to_day: "1", to_month: "12", to_year: "2023") }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:from_date]).to include("Enter a from date")
        end
      end

      context "with missing to date" do
        subject { described_class.new(from_day: "1", from_month: "6", from_year: "2023") }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:to_date]).to include("Enter a to date")
        end
      end

      context "with invalid from date" do
        subject { described_class.new(from_day: "32", from_month: "13", from_year: "invalid", to_day: "1", to_month: "12", to_year: "2023") }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:from_date]).to include("Enter a valid from date")
        end
      end

      context "with invalid to date" do
        subject { described_class.new(from_day: "1", from_month: "6", from_year: "2023", to_day: "0", to_month: "0", to_year: "2023") }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:to_date]).to include("Enter a valid to date")
        end
      end

      context "when from date is after to date" do
        subject do
          described_class.new(
            from_day: "1", from_month: "12", from_year: "2023",
            to_day: "1", to_month: "1", to_year: "2023"
          )
        end

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:to_date]).to include("To date must be after from date")
        end

        it "does not run data validation when date range is illogical" do
          expect(subject).not_to receive(:degrees_scope)
          subject.valid?
        end
      end

      context "when date range exceeds 1 year" do
        subject do
          described_class.new(
            from_day: "1", from_month: "1", from_year: "2023",
            to_day: "2", to_month: "1", to_year: "2024"
          )
        end

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:to_date]).to include("Date range cannot exceed 1 year")
        end
      end

      context "when date range is exactly 1 year" do
        let!(:trainee) { create(:trainee, :trn_received) }
        let!(:degree) { create(:degree, trainee: trainee, created_at: Date.new(2023, 6, 1)) }

        subject do
          described_class.new(
            from_day: "1", from_month: "1", from_year: "2023",
            to_day: "1", to_month: "1", to_year: "2024"
          )
        end

        it { is_expected.to be_valid }
      end

      context "when no data exists for the period" do
        subject do
          described_class.new(
            from_day: "1", from_month: "1", from_year: "2125",
            to_day: "31", to_month: "12", to_year: "2125"
          )
        end

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:base]).to include("No degree data found between 1 January 2125 and 31 December 2125")
        end
      end

      context "when partial date fields are provided" do
        subject { described_class.new(from_day: "1", from_month: "6", to_day: "1", to_month: "12", to_year: "2023") }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:from_date]).to include("Enter a valid from date")
        end
      end
    end

    describe "#degrees_scope" do
      let!(:trainee_with_trn) { create(:trainee, :trn_received) }
      let!(:trainee_without_trn) { create(:trainee, trn: nil) }
      let!(:degree_in_range) { create(:degree, trainee: trainee_with_trn, created_at: Date.new(2023, 6, 15)) }
      let!(:degree_out_of_range) { create(:degree, trainee: trainee_with_trn, created_at: Date.new(2024, 1, 1)) }
      let!(:degree_no_trn) { create(:degree, trainee: trainee_without_trn, created_at: Date.new(2023, 6, 15)) }

      subject do
        described_class.new(
          from_day: "1", from_month: "1", from_year: "2023",
          to_day: "31", to_month: "12", to_year: "2023"
        )
      end

      it "returns only degrees for trainees with TRNs within the date range" do
        expect(subject.degrees_scope).to include(degree_in_range)
        expect(subject.degrees_scope).not_to include(degree_out_of_range)
        expect(subject.degrees_scope).not_to include(degree_no_trn)
      end
    end
  end
end

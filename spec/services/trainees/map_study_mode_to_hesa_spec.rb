# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe MapStudyModeToHesa do
    describe "::call" do
      subject(:result) { described_class.call(trainee:) }

      let(:trainee) { build(:trainee, study_mode:) }

      before do
        trainee.build_hesa_trainee_detail(course_study_mode:) if defined?(course_study_mode)
      end

      context "when no study mode is selected" do
        let(:study_mode) { nil }

        context "with a stored course_study_mode" do
          let(:course_study_mode) { "01" }

          it "preserves the stored value" do
            expect(result).to eq("01")
          end
        end

        context "without a stored course_study_mode" do
          let(:course_study_mode) { nil }

          it { is_expected.to be_nil }
        end
      end

      context "when full time is selected" do
        let(:study_mode) { "full_time" }

        context "and the stored code already maps to full time" do
          %w[01 02 63].each do |code|
            context "stored as #{code}" do
              let(:course_study_mode) { code }

              it "preserves the stored value" do
                expect(result).to eq(code)
              end
            end
          end
        end

        context "and the stored code maps to part time" do
          let(:course_study_mode) { "31" }

          it "sets the canonical full time code" do
            expect(result).to eq("01")
          end
        end

        context "and there is no stored code" do
          let(:course_study_mode) { nil }

          it "sets the canonical full time code" do
            expect(result).to eq("01")
          end
        end
      end

      context "when part time is selected" do
        let(:study_mode) { "part_time" }

        context "and the stored code already maps to part time" do
          %w[31 64].each do |code|
            context "stored as #{code}" do
              let(:course_study_mode) { code }

              it "preserves the stored value" do
                expect(result).to eq(code)
              end
            end
          end
        end

        context "and the stored code maps to full time" do
          let(:course_study_mode) { "01" }

          it "sets the canonical part time code" do
            expect(result).to eq("31")
          end
        end

        context "and there is no stored code" do
          let(:course_study_mode) { nil }

          it "sets the canonical part time code" do
            expect(result).to eq("31")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Funding
  describe View do
    let(:data_model) { Funding::FormValidator.new(trainee) }
    let!(:current_academic_cycle) { create(:academic_cycle) }
    let!(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let(:start_academic_cycle) { next_academic_cycle }

    before { render_inline(View.new(data_model: trainee, editable: true)) }

    context "early years graduate entry" do
      let(:bursary_tier) { BURSARY_TIERS.keys.first }

      context "trainee with grant and tiered bursary" do
        let(:trainee) do
          create(:trainee, :with_grant_and_tiered_bursary, start_academic_cycle:, applying_for_grant:, applying_for_bursary:, bursary_tier:)
        end

        context "applying without grant and with tiered bursary" do
          let(:applying_for_grant) { false }
          let(:applying_for_bursary) { true }

          it "renders grant text" do
            expect(rendered_content).to have_text("Not grant funded")
          end

          it "renders tiered bursary text" do
            expect(rendered_content).to have_text("Applied for Tier 1")
            expect(rendered_content).to have_text("£5,000 estimated bursary")
          end
        end

        context "applying with grant and with tiered bursary" do
          let(:applying_for_grant) { true }
          let(:applying_for_bursary) { true }

          it "renders grant text" do
            expect(rendered_content).to have_text("Grant applied for")
            expect(rendered_content).to have_text("£5,000 estimated grant")
          end

          it "renders tiered bursary text" do
            expect(rendered_content).to have_text("Applied for Tier 1")
            expect(rendered_content).to have_text("£5,000 estimated bursary")
          end

          context "applying without grant and without tiered bursary" do
            let(:applying_for_grant) { false }
            let(:applying_for_bursary) { false }
            let(:bursary_tier) { nil }

            it "renders grant text" do
              expect(rendered_content).to have_text("Not grant funded")
            end

            it "renders tiered bursary text" do
              expect(rendered_content).to have_text("Not funded")
            end
          end
        end
      end

      context "trainee with tiered bursary" do
        let(:trainee) do
          create(:trainee, :early_years_postgrad, :with_tiered_bursary, start_academic_cycle:, bursary_tier:)
        end

        it "does not renders grant text" do
          expect(rendered_content).not_to have_text("grant")
        end

        it "renders tiered bursary text" do
          expect(rendered_content).to have_text("Applied for Tier 1")
          expect(rendered_content).to have_text("£5,000 estimated bursary")
        end
      end
    end

    context "on opt-in (undergrad) route" do
      let(:state) { :draft }
      let(:route) { "opt_in_undergrad" }
      let(:training_initiative) { ROUTE_INITIATIVES_ENUMS.keys.first }
      let(:trainee) do
        build(:trainee,
              state,
              :with_start_date,
              :with_study_mode_and_course_dates,
              training_initiative: training_initiative,
              training_route: route,
              start_academic_cycle: start_academic_cycle,
              applying_for_bursary: true,
              course_subject_one: subject_specialism.name)
      end

      let(:subject_specialism) { create(:subject_specialism, name: AllocationSubjects::MATHEMATICS) }
      let(:amount) { 9000 }
      let(:funding_method) do
        create(
          :funding_method,
          training_route: route,
          amount: amount,
          academic_cycle: start_academic_cycle,
        )
      end

      context "when there is a bursary available" do
        before do
          create(:funding_method_subject,
                 funding_method: funding_method,
                 allocation_subject: subject_specialism.allocation_subject)
          render_inline(View.new(data_model:))
        end

        it "renders if the trainee selects mathematics" do
          expect(rendered_content).to have_text("£9,000 estimated bursary")
        end
      end

      context "when there is no bursary available" do
        before do
          render_inline(View.new(data_model: trainee))
        end

        it "doesn't render if the trainee selects drama" do
          expect(rendered_content).not_to have_text("Bursary applied for")
        end
      end
    end

    context "assessment only route" do
      let(:state) { :draft }
      let(:route) { "assessment_only" }
      let(:training_initiative) { ROUTE_INITIATIVES_ENUMS.keys.first }

      let(:trainee) do
        build(:trainee,
              state,
              :with_start_date,
              :with_study_mode_and_course_dates,
              training_initiative: training_initiative,
              training_route: route,
              start_academic_cycle: start_academic_cycle,
              applying_for_bursary: applying_for_bursary,
              course_subject_one: course_subject_one)
      end

      let(:course_subject_one) { nil }
      let(:applying_for_bursary) { nil }

      describe "on training initiative" do
        let(:training_initiative) { ROUTE_INITIATIVES.keys.first }

        it "renders" do
          expect(rendered_content).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change link" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end

        describe "has no bursary" do
          before do
            create(:funding_method, academic_cycle: start_academic_cycle)
            render_inline(View.new(data_model:))
          end

          it "doesnt not render bursary row" do
            expect(rendered_content).not_to have_text("Bursary applied for")
          end

          context "and it non-draft" do
            let(:state) { :trn_received }

            before do
              render_inline(View.new(data_model: trainee))
            end

            it "renders bursary not available" do
              expect(rendered_content).to have_text("Not applicable")
            end
          end
        end

        describe "has bursary" do
          let(:trainee) {
            create(
              :trainee,
              :with_provider_led_bursary,
              funding_amount: 24000,
              applying_for_bursary: applying_for_bursary,
              start_academic_cycle: start_academic_cycle,
            )
          }

          before do
            render_inline(View.new(data_model: trainee, editable: true))
          end

          describe "bursary funded" do
            let(:applying_for_bursary) { true }

            it "renders" do
              expect(rendered_content).to have_text("Bursary applied for")
              expect(rendered_content).to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end

          describe "not bursary funded" do
            let(:applying_for_bursary) { false }

            it "renders" do
              expect(rendered_content).to have_text("Not funded")
              expect(rendered_content).not_to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end
        end
      end

      describe "not on training initiative" do
        let(:training_initiative) { "no_initiative" }

        it "renders" do
          expect(rendered_content).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change links" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end
      end
    end

    context "with grant" do
      let(:trainee) { create(:trainee, :with_grant, funding_amount: 25000, applying_for_grant: applying_for_grant, start_academic_cycle: start_academic_cycle) }

      before do
        create(:funding_method, academic_cycle: start_academic_cycle)
        render_inline(View.new(data_model: trainee, editable: true))
      end

      context "when trainee applying_for_grant is true" do
        let(:applying_for_grant) { true }

        it "renders grant text" do
          expect(rendered_content).to have_text("Grant applied for")
          expect(rendered_content).to have_text("£25,000 estimated grant")
        end
      end

      context "when trainee applying_for_grant is false" do
        let(:applying_for_grant) { false }

        it "renders grant text" do
          expect(rendered_content).to have_text("Not grant funded")
        end

        it "has correct change link" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit", text: "Change")
        end
      end

      context "when trainee applying_for_grant is nil" do
        let(:applying_for_grant) { nil }

        it "renders grant text" do
          expect(rendered_content).to have_text("Funding method is missing")
        end

        it "has correct change link" do
          expect(rendered_content).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit", text: "Enter an answer")
        end
      end
    end

    context "when trainee has a hesa record" do
      describe "applying for bursary row" do
        context "when applying for bursary" do
          let(:trainee) { create(:trainee, :imported_from_hesa, applying_for_bursary: true) }

          subject { rendered_content }

          it { is_expected.to have_text("Yes") }
        end

        context "when not applying for bursary" do
          let(:trainee) { create(:trainee, :imported_from_hesa, applying_for_bursary: false) }

          subject { rendered_content }

          it { is_expected.to have_text("No") }
        end
      end

     describe "fund code row" do
        let(:trainee) { create(:trainee, :imported_from_hesa, :with_hesa_trainee_detail) }

        context "when trainee has eligible fund code" do
          let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }
          let(:trainee) { create(:trainee, :imported_from_hesa, :with_hesa_trainee_detail) }

          before do
            trainee.hesa_trainee_detail.update!(fund_code:)
            render_inline(View.new(data_model: trainee))
          end

          it "renders the fund code with description" do
            expect(rendered_content).to have_text("Fund code")
            expect(rendered_content).to have_text("Eligible for funding from the DfE")
          end
        end

        context "when trainee has not eliglble fund code" do
          let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
          let(:trainee) { create(:trainee, :imported_from_hesa, :with_hesa_trainee_detail) }

          before do
            trainee.hesa_trainee_detail.update!(fund_code:)
            render_inline(View.new(data_model: trainee))
          end

          it "renders the fund code with description" do
            expect(rendered_content).to have_text("Fund code")
            expect(rendered_content).to have_text("Not fundable by funding council/body")
          end
        end

        context "when trainee has no fund code" do
          before do
            trainee.hesa_trainee_detail.update!(fund_code: nil)
            render_inline(View.new(data_model: trainee))
          end

          it "renders fund code row with empty value" do
            expect(rendered_content).to have_text("Fund code")
            expect(rendered_content).to have_text("Not provided")
          end
        end
      end

      describe "hesa selected bursary level" do
        let(:trainee) { create(:trainee, :imported_from_hesa, applying_for_bursary: true) }
        let(:hesa_bursary_code) { trainee.hesa_students.first.bursary_level }

        it "renders the hesa bursary level along with the code" do
          expect(rendered_content).to have_text("#{hesa_bursary_code} - #{Hesa::CodeSets::BursaryLevels::VALUES[hesa_bursary_code]}")
        end
      end
    end

    describe "when we don't know the funding rules for the trainee's cycle" do
      let(:trainee) { create(:trainee, :with_start_date, applying_for_bursary: true, start_academic_cycle: start_academic_cycle) }

      it "doesn't render the funding row" do
        expect(rendered_content).not_to have_text("Funding method")
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Funding
  describe View do
    before { render_inline(View.new(data_model: trainee)) }

    context "with tieried bursary" do
      let(:trainee) do
        build(:trainee,
              :early_years_postgrad,
              applying_for_bursary: true,
              bursary_tier: BURSARY_TIERS.keys.first)
      end

      it "renders tiered bursary text" do
        expect(rendered_component).to have_text("Applied for Tier 1")
        expect(rendered_component).to have_text("£5,000 estimated bursary")
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
              applying_for_bursary: true,
              course_subject_one: subject_specialism.name)
      end

      let(:subject_specialism) { create(:subject_specialism, name: AllocationSubjects::MATHEMATICS) }
      let(:amount) { 9000 }
      let(:funding_method) { create(:funding_method, training_route: route, amount: amount) }

      context "when there is a bursary available" do
        before do
          create(:funding_method_subject,
                 funding_method: funding_method,
                 allocation_subject: subject_specialism.allocation_subject)
          render_inline(View.new(data_model: trainee))
        end

        it "renders if the trainee selects mathematics" do
          expect(rendered_component).to have_text("£9,000 estimated bursary")
        end
      end

      context "when there is no bursary available" do
        before do
          render_inline(View.new(data_model: trainee))
        end

        it "doesn't render if the trainee selects drama" do
          expect(rendered_component).not_to have_text("Bursary applied for")
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
              applying_for_bursary: applying_for_bursary,
              course_subject_one: course_subject_one)
      end

      let(:course_subject_one) { nil }
      let(:applying_for_bursary) { nil }

      describe "on training initiative" do
        let(:training_initiative) { ROUTE_INITIATIVES.keys.first }

        it "renders" do
          expect(rendered_component).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change link" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end

        describe "has no bursary" do
          before do
            render_inline(View.new(data_model: trainee))
          end

          it "doesnt not render bursary row" do
            expect(rendered_component).not_to have_text("Bursary applied for")
          end

          context "and it non-draft" do
            let(:state) { :trn_received }

            it "renders bursary not available" do
              expect(rendered_component).to have_text("Not applicable")
            end
          end
        end

        describe "has bursary" do
          let(:subject_specialism) { create(:subject_specialism, name: AllocationSubjects::MUSIC) }
          let(:amount) { 24_000 }
          let(:funding_method) { create(:funding_method, training_route: route, amount: amount) }

          let(:course_subject_one) { subject_specialism.name }

          before do
            create(:funding_method_subject,
                   funding_method: funding_method,
                   allocation_subject: subject_specialism.allocation_subject)

            render_inline(View.new(data_model: trainee))
          end

          describe "bursary funded" do
            let(:applying_for_bursary) { true }

            it "renders" do
              expect(rendered_component).to have_text("Bursary applied for")
              expect(rendered_component).to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end

          describe "not bursary funded" do
            let(:applying_for_bursary) { false }

            it "renders" do
              expect(rendered_component).to have_text("Not funded")
              expect(rendered_component).not_to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end
        end
      end

      describe "not on training initiative" do
        let(:training_initiative) { "no_initiative" }

        it "renders" do
          expect(rendered_component).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change links" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end
      end
    end

    context "with grant" do
      let!(:allocation_subject) { create(:allocation_subject, name: "Chemistry") }
      let!(:subject_specialism) do
        create(:subject_specialism, name: trainee.course_subject_one, allocation_subject: allocation_subject)
      end

      let(:amount) { 25_000 }
      let!(:funding_method) do
        create(:funding_method, funding_type: "grant", training_route: trainee.training_route, amount: amount)
      end

      let!(:funding_method_subject) do
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: allocation_subject)
      end

      before do
        render_inline(View.new(data_model: trainee))
      end

      context "when trainee applying_for_grant is true" do
        let!(:trainee) do
          create(:trainee,
                 :with_start_date,
                 :with_study_mode_and_course_dates,
                 :school_direct_salaried,
                 :with_grant,
                 course_subject_one: "chemistry")
        end

        it "renders grant text" do
          expect(rendered_component).to have_text("Grant applied for")
          expect(rendered_component).to have_text("£25,000 estimated grant")
        end
      end

      context "when trainee applying_for_grant is false" do
        let!(:trainee) do
          create(:trainee,
                 :with_start_date,
                 :with_study_mode_and_course_dates,
                 :school_direct_salaried,
                 :with_grant,
                 course_subject_one: "chemistry",
                 applying_for_grant: false)
        end

        it "renders grant text" do
          expect(rendered_component).to have_text("Not grant funded")
        end

        it "has correct change link" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit", text: "Change")
        end
      end

      context "when trainee applying_for_grant is nil" do
        let!(:trainee) do
          create(:trainee,
                 :with_start_date,
                 :with_study_mode_and_course_dates,
                 :school_direct_salaried,
                 :with_grant,
                 course_subject_one: "chemistry",
                 applying_for_grant: nil)
        end

        it "renders grant text" do
          expect(rendered_component).to have_text("Funding method is missing")
        end

        it "has correct change link" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit", text: "Enter an answer")
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module RecordDetails
  describe View do
    include SummaryHelper
    include ActionView::Helpers::SanitizeHelper

    let(:state) { :trn_received }
    let(:training_route) { TRAINING_ROUTE_ENUMS[:assessment_only] }
    let(:provider) { create(:provider) }
    let(:trainee) do
      create(
        :trainee,
        :imported_from_hesa,
        state,
        training_route,
        trn: Faker::Number.number(digits: 10),
        provider: provider,
        hesa_id: hesa_id,
        study_mode: TRAINEE_STUDY_MODE_ENUMS["part_time"],
        itt_start_date: current_academic_cycle.start_date,
        itt_end_date: next_academic_cycle.end_date,
      )
    end
    let(:hesa_id) { Faker::Number.number(digits: 10).to_s }
    let(:trainee_status) { "trainee-status" }
    let(:trainee_progress) { "trainee-progress" }
    let(:timeline_event) { double(date: Time.zone.today) }
    let(:current_academic_cycle) { create(:academic_cycle) }
    let(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }

    context "when :show_provider is true" do
      let(:show_change_provider) { false }

      before do
        render_inline(
          View.new(
            trainee: trainee,
            last_updated_event: timeline_event,
            show_provider: true,
            editable: true,
            show_change_provider: show_change_provider,
          ),
        )
      end

      it "renders the provider name and code" do
        expect(rendered_content).to have_text(provider.name_and_code)
      end

      context "when current user is NOT an administrator" do
        it "does not render a change link" do
          expect(rendered_content).to have_css(".govuk-summary-list__row.accredited-provider .govuk-summary-list__actions a", count: 0)
        end
      end

      context "when current user is an administrator" do
        let(:show_change_provider) { true }

        it "renders a change link" do
          expect(rendered_content).to have_css(".govuk-summary-list__row.accredited-provider .govuk-summary-list__actions a", count: 1)
        end
      end
    end

    context "when :show_provider is not true" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "renders the provider name and code" do
        expect(rendered_content).not_to have_text(provider.name_and_code)
      end
    end

    context "when :show_record_source is true" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, show_record_source: true))
      end

      it "renders the record source" do
        expect(rendered_content).to have_text(I18n.t("record_details.view.record_source.title"))
      end
    end

    context "when :show_record_source is false" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, show_record_source: false))
      end

      it "does not render the record source" do
        expect(rendered_content).not_to have_text(I18n.t(".record_details.view.record_source"))
      end
    end

    context "when no timeline events exist" do
      let(:timeline_event) { nil }

      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "renders the updated_at date in the Last updated row" do
        expect(rendered_content).to have_text("Last updated#{date_for_summary_view(trainee.updated_at)}")
      end
    end

    context "when any data has not been provided" do
      before do
        trainee.provider_trainee_id = nil
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, editable: true))
      end

      it "tells the user that the data is missing" do
        expect(rendered_content).to have_text(t("components.confirmation.missing"))
      end
    end

    context "when data has been provided" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "renders the trainee ID" do
        expect(rendered_content).to have_text(trainee.provider_trainee_id)
      end

      it "renders the trainee's last timeline event date" do
        expect(rendered_content).to have_text(date_for_summary_view(timeline_event.date))
      end

      it "renders the HESA ID" do
        expect(rendered_content).to have_text(trainee.hesa_id)
      end

      it "renders the start year" do
        expect(rendered_content).to have_text(current_academic_cycle.label)
      end

      it "renders the end year" do
        expect(rendered_content).to have_text(next_academic_cycle.label)
      end

      context "but the trainee has no trn or submitted_for_trn_at" do
        let(:trainee) { create(:trainee, :withdrawn, trn: nil, submitted_for_trn_at: nil) }

        it "renders the page" do
          expect(rendered_content).to have_text(trainee.provider_trainee_id)
        end
      end

      context "when trainee state is submitted_for_trn" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }

        it "renders the trn submission date" do
          expect(rendered_content).to have_text(date_for_summary_view(trainee.submitted_for_trn_at))
        end
      end

      context "when trainee has a hpitt_provider" do
        let(:trainee) { build(:trainee, :with_hpitt_provider, :trn_received) }

        it "renders the trainee's region" do
          expect(rendered_content).to have_text(trainee.region)
        end
      end

      context "when trainee state is recommended_for_award" do
        let(:state) { :recommended_for_award }

        it "renders the trainee recommended date" do
          expect(rendered_content).to have_text(date_for_summary_view(trainee.recommended_for_award_at))
        end

        context "and the trainee is an EY trainee" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }

          it "renders the trainee recommended date" do
            expect(rendered_content).to have_text(date_for_summary_view(trainee.recommended_for_award_at))
          end
        end
      end

      context "when trainee state is awarded" do
        let(:state) { :awarded }

        it "renders the trainee awarded date" do
          expect(rendered_content).to have_text(date_for_summary_view(trainee.awarded_at))
        end

        context "and the trainee is an EY trainee" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }

          it "renders the trainee awarded date" do
            expect(rendered_content).to have_text(date_for_summary_view(trainee.awarded_at))
          end
        end
      end
    end

    context "Trainee start date row" do
      context "when ITT start date in the future" do
        before do
          trainee.commencement_status = :itt_not_yet_started
          trainee.itt_start_date = 30.days.from_now.to_date
          render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
        end

        it "renders itt has not started text" do
          expect(rendered_content).to have_text(strip_tags(t("record_details.view.itt_has_not_started")))
        end

        it "does not render link" do
          expect(rendered_content).to have_css(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 0)
        end
      end

      context "when ITT start date in the past" do
        before do
          trainee.commencement_status = :itt_started_on_time
          trainee.itt_start_date = 5.days.ago.to_date
        end

        context "trainee_start_date is set" do
          let(:trainee_start_date) { 5.days.from_now.to_date }

          before do
            create(:academic_cycle, one_after_next_cycle: true)
            trainee.trainee_start_date = trainee_start_date
            render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, editable: true))
          end

          it "renders trainee_start_date" do
            expect(rendered_content).to have_text(date_for_summary_view(trainee_start_date))
          end

          it "renders link to trainee start date form" do
            expect(rendered_content).to have_css(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 1)
            expect(rendered_content).to have_link(href: "/trainees/#{trainee.to_param}/trainee-start-date/edit")
          end
        end

        context "trainee_start_date is not set" do
          before do
            create(:academic_cycle, :previous) if create_previous_academic_year?
            trainee.trainee_start_date = nil
            render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, editable: true))
          end

          it "renders not provided" do
            expect(rendered_content).to have_text(t("record_details.view.not_provided"))
          end

          it "renders link to trainee start status form" do
            expect(rendered_content).to have_css(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 1)
            expect(rendered_content).to have_link(href: "/trainees/#{trainee.to_param}/trainee-start-status/edit")
          end

          context "when deferred" do
            let(:trainee) do
              create(:trainee, :deferred, itt_start_date: Time.zone.today)
            end

            it "renders the trainee deferred before course started message" do
              expect(rendered_content).to have_text(strip_tags(t("record_details.view.deferred_before_itt_started")))
            end
          end
        end
      end

      context "with no ITT start date and a hesa record" do
        before do
          trainee.commencement_status = :itt_started_on_time
          trainee.itt_start_date = nil
          trainee.hesa_id = 1
          render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
        end

        it "renders the not provided from hesa message" do
          expect(rendered_content).to have_text(I18n.t("components.confirmation.not_provided_from_hesa_update"))
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module RecordDetails
  describe View do
    include SummaryHelper

    let(:state) { :trn_received }
    let(:training_route) { TRAINING_ROUTE_ENUMS[:assessment_only] }
    let(:provider) { create(:provider) }
    let(:trainee) { create(:trainee, state, training_route, trn: Faker::Number.number(digits: 10), provider: provider) }
    let(:trainee_status) { "trainee-status" }
    let(:trainee_progress) { "trainee-progress" }
    let(:timeline_event) { double(date: Time.zone.today) }

    context "when system admin is true" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, system_admin: true))
      end

      it "renders the provider name and code" do
        expect(rendered_component).to have_text(provider.name_and_code)
      end
    end

    context "when system admin is false" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event, system_admin: false))
      end

      it "renders the provider name and code" do
        expect(rendered_component).not_to have_text(provider.name_and_code)
      end
    end

    context "when any data has not been provided" do
      before do
        trainee.trainee_id = nil
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "tells the user that the data is missing" do
        expect(rendered_component).to have_text(t("components.confirmation.missing"))
      end
    end

    context "when data has been provided" do
      before do
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "renders the trainee ID" do
        expect(rendered_component).to have_text(trainee.trainee_id)
      end

      it "renders the trainee's last timeline event date" do
        expect(rendered_component).to have_text(date_for_summary_view(timeline_event.date))
      end

      it "renders the trainee record created date" do
        expect(rendered_component).to have_text(date_for_summary_view(trainee.created_at))
      end

      context "when trainee state is submitted_for_trn" do
        let(:trainee) { create(:trainee, :submitted_for_trn) }

        it "renders the trn submission date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.submitted_for_trn_at))
        end
      end

      context "when trainee has a hpitt_provider" do
        let(:trainee) { build(:trainee, :with_hpitt_provider, :trn_received) }

        it "renders the trainee's region" do
          expect(rendered_component).to have_text(trainee.region)
        end
      end

      context "when trainee state is deferred" do
        let(:state) { :deferred }

        it "renders the trainee deferral date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.defer_date))
        end

        it "renders the trainee status tag" do
          expect(rendered_component).to have_text("deferred")
        end
      end

      context "when trainee state is withdrawn" do
        let(:state) { :withdrawn }

        it "renders the trainee withdrawal date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.withdraw_date))
        end

        it "renders the trainee state" do
          expect(rendered_component).to have_text(I18n.t("record_details.view.status_date_prefix.#{trainee.state}"))
        end
      end

      context "when trainee state is recommended_for_award" do
        let(:state) { :recommended_for_award }

        it "renders the trainee recommended date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.recommended_for_award_at))
        end

        context "and the trainee is an EY trainee" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }

          it "renders the trainee recommended date" do
            expect(rendered_component).to have_text(date_for_summary_view(trainee.recommended_for_award_at))
          end
        end
      end

      context "when trainee state is awarded" do
        let(:state) { :awarded }

        it "renders the trainee awarded date" do
          expect(rendered_component).to have_text(date_for_summary_view(trainee.awarded_at))
        end

        context "and the trainee is an EY trainee" do
          let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }

          it "renders the trainee awarded date" do
            expect(rendered_component).to have_text(date_for_summary_view(trainee.awarded_at))
          end
        end
      end

      context "when trainee start date is in the future" do
        let(:trainee) {
          create(:trainee, state, training_route, trn: Faker::Number.number(digits: 10), provider: provider,
                                                  course_start_date: Time.zone.tomorrow)
        }

        it "does not render the change link" do
          expect(rendered_component).not_to have_link(t("change"), href: "/trainees/#{trainee.slug}/trainee-start-date/edit")
        end
      end
    end

    context "Trainee start date row" do
      context "when ITT start date in the future" do
        before do
          trainee.commencement_status = :itt_not_yet_started
          trainee.course_start_date = 30.days.from_now.to_date
          render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
        end

        it "renders itt has not started text" do
          expect(rendered_component).to have_text(t("record_details.view.itt_has_not_started"))
        end

        it "does not render link" do
          expect(rendered_component).to have_selector(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 0)
        end
      end

      context "when ITT start date in the past" do
        before do
          trainee.commencement_status = :itt_started_on_time
          trainee.course_start_date = 5.days.ago.to_date
        end

        context "commencement_date is set" do
          let(:commencement_date) { 5.days.from_now.to_date }

          before do
            trainee.commencement_date = commencement_date
            render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
          end

          it "renders commencement_date" do
            expect(rendered_component).to have_text(date_for_summary_view(commencement_date))
          end

          it "renders link to trainee start date form" do
            expect(rendered_component).to have_selector(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 1)
            expect(rendered_component).to have_link(href: "/trainees/#{trainee.to_param}/trainee-start-date/edit")
          end
        end

        context "commencement_date is not set" do
          before do
            trainee.commencement_date = nil
            render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
          end

          it "renders not provided" do
            expect(rendered_component).to have_text(t("record_details.view.not_provided"))
          end

          it "renders link to trainee start status form" do
            expect(rendered_component).to have_selector(".govuk-summary-list__row.trainee-start-date .govuk-summary-list__actions a", count: 1)
            expect(rendered_component).to have_link(href: "/trainees/#{trainee.to_param}/trainee-start-status/edit")
          end
        end
      end
    end
  end
end

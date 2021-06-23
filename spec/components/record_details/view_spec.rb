# frozen_string_literal: true

require "rails_helper"

module RecordDetails
  describe View do
    include SummaryHelper

    let(:state) { :trn_received }
    let(:training_route) { TRAINING_ROUTE_ENUMS[:assessment_only] }
    let(:trainee) { create(:trainee, state, training_route, trn: Faker::Number.number(digits: 10)) }
    let(:trainee_status) { "trainee-status" }
    let(:trainee_progress) { "trainee-progress" }
    let(:timeline_event) { double(date: Time.zone.today) }

    context "when trainee_id data has not been provided" do
      before do
        trainee.trainee_id = nil
        render_inline(View.new(trainee: trainee, last_updated_event: timeline_event))
      end

      it "tells the user that no data has been entered for trainee ID" do
        expect(rendered_component).to have_text(t("components.confirmation.not_provided"))
      end
    end

    context "when trainee_id data has been provided" do
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
    end
  end
end

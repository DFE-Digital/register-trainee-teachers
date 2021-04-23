# frozen_string_literal: true

require "rails_helper"

module ApplicationRecordCard
  describe View do
    alias_method :component, :page

    let(:trainee) { Trainee.new(created_at: Time.zone.now) }

    before do
      render_inline(described_class.new(record: trainee))
    end

    context "when the Trainee has no names" do
      it "renders 'Draft record'" do
        expect(component.find("h3")).to have_text("Draft record")
      end
    end

    context "when the Trainee has no subject" do
      it "renders 'No subject provided'" do
        expect(component.find(".app-application-card__subject")).to have_text("No subject provided")
      end
    end

    context "when the Trainee has no route" do
      it "renders 'No route provided'" do
        expect(component.find(".app-application-card__route")).to have_text("No route provided")
      end
    end

    context "when the Trainee has no trainee_id" do
      it "does not render trainee ID" do
        expect(component).to_not have_selector(".app-application-card__id")
      end
    end

    context "when the Trainee has no trn" do
      it "does not render trn" do
        expect(component).to_not have_selector(".app-application-card__trn")
      end
    end

    describe "status" do
      [
        { state: :draft, colour: "grey", text: "draft" },
        { state: :submitted_for_trn, colour: "turquoise", text: "pending trn" },
        { state: :trn_received, colour: "blue", text: "trn received" },
        { state: :recommended_for_qts, colour: "purple", text: "qts recommended" },
        { state: :qts_awarded, colour: "", text: "qts awarded" },
        { state: :deferred, colour: "yellow", text: "deferred" },
        { state: :withdrawn, colour: "red", text: "withdrawn" },
      ].each do |state_expectation|
        context "when state is #{state_expectation[:state]}" do
          let(:trainee) { build(:trainee, state_expectation[:state], created_at: Time.zone.now) }

          it "renders '#{state_expectation[:text]}'" do
            # byebug
            expect(component).to have_selector(".govuk-tag", text: state_expectation[:text])
          end

          it "sets the colour to #{state_expectation[:colour]}" do
            colour = state_expectation[:colour]
            expected_tag_class = ".govuk-tag"
            expected_tag_class = "#{expected_tag_class}--#{colour}" if colour.present?

            expect(component).to have_selector(expected_tag_class)
          end
        end
      end
    end

    context "when a trainee with all their details filled in" do
      let(:trainee) do
        Timecop.freeze(Time.zone.local(2020, 1, 1)) do
          build(
            :trainee,
            id: 1,
            first_names: "Teddy",
            last_name: "Smith",
            subject: "Designer",
            training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
            trainee_id: "132456",
            created_at: Time.zone.now,
            trn: "789456",
          )
        end
      end

      before do
        render_inline(described_class.new(
                        record: trainee,
                      ))
      end

      it "renders trainee ID" do
        expect(component.find(".app-application-card__id")).to have_text("Trainee ID: 132456")
      end

      it "renders trn" do
        expect(component.find(".app-application-card__trn")).to have_text("TRN: 789456")
      end

      it "renders updated at" do
        expect(component.find(".app-application-card__submitted")).to have_text("Updated: 1 January 2020")
      end

      it "renders trainee name " do
        expect(component.find("h3")).to have_text("Teddy Smith")
      end

      it "renders subject" do
        expect(component.find(".app-application-card__subject")).to have_text("Designer")
      end

      it "renders route if there is no route" do
        expect(component.find(".app-application-card__route")).to have_text(t("activerecord.attributes.trainee.training_routes.assessment_only"))
      end
    end
  end
end

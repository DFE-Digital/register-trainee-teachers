# frozen_string_literal: true

require "rails_helper"

module ApplicationRecordCard
  describe View do
    let(:provider) { create(:provider, :with_courses) }
    let(:course) { provider.courses.first }
    let(:current_user) do
      double(UserWithOrganisationContext, system_admin?: false, lead_partner?: false)
    end
    let(:trainee) { create(:trainee, first_names: nil, provider: provider, course_uuid: course.uuid, provider_trainee_id: nil) }
    let(:cycle) { create(:academic_cycle, cycle_year: 2019) }

    before do
      allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
      allow(trainee).to receive(:timeline).and_return([double(date: Time.zone.now)])
      render_inline(described_class.new(record: trainee, current_user: current_user))
    end

    it "does not render provider name" do
      expect(rendered_content).not_to have_css(".application-record-card__provider_name")
    end

    context "when system admin user" do
      let(:current_user) do
        double(UserWithOrganisationContext, system_admin?: true, lead_partner?: false)
      end

      it "renders provider name" do
        expect(rendered_content).to have_css(".application-record-card__provider_name", text: provider.name_and_code)
      end

      it "renders the record source" do
        expect(rendered_content).to have_css(".application-record-card__record_source", text: I18n.t("components.application_record_card.record_source.title"))
      end
    end

    context "when lead partner user" do
      let(:current_user) do
        double(UserWithOrganisationContext, system_admin?: false, lead_partner?: true)
      end

      it "renders provider name" do
        expect(rendered_content).to have_css(".application-record-card__provider_name", text: provider.name_and_code)
      end
    end

    context "when the Trainee has no names" do
      it "renders 'Draft record'" do
        expect(rendered_content).to have_text("Draft record")
      end
    end

    context "when the Trainee has no subject" do
      it "renders the course name" do
        expect(rendered_content).to have_text(course.name)
      end

      context "and is an Early Years trainee" do
        let(:trainee) { create(:trainee, :early_years_undergrad) }

        it "renders 'Early years teaching'" do
          expect(rendered_content).to have_text("Early years teaching")
        end
      end
    end

    context "when the Trainee has no route" do
      let(:trainee) { build(:trainee, training_route: nil, updated_at: Time.zone.now) }

      it "renders 'No route provided'" do
        expect(rendered_content).to have_text("No route provided")
      end
    end

    context "when the Trainee has no trainee_id" do
      it "does not render trainee ID" do
        expect(rendered_content).not_to have_css(".application-record-card__id")
      end
    end

    context "when the Trainee has no trn" do
      it "does not render trn" do
        expect(rendered_content).not_to have_css(".application-record-card__trn")
      end
    end

    describe "status" do
      [
        { state: :draft, colour: "grey", text: "Draft" },
        { state: :submitted_for_trn, colour: "turquoise", text: "Pending TRN" },
        { state: :trn_received, colour: "blue", text: "TRN received" },
        { state: :recommended_for_award, colour: "purple", text: "QTS pending" },
        { state: :awarded, colour: "", text: "Holds QTS" },
        { state: :deferred, colour: "yellow", text: "Deferred" },
        { state: :withdrawn, colour: "red", text: "Withdrawn" },
      ].each do |state_expectation|
        context "when state is #{state_expectation[:state]}" do
          let(:trainee) { create(:trainee, state_expectation[:state], training_route: TRAINING_ROUTE_ENUMS[:assessment_only]) }

          it "renders '#{state_expectation[:text]}'" do
            expect(rendered_content).to have_css(".govuk-tag", text: state_expectation[:text])
          end

          it "sets the colour to #{state_expectation[:colour]}" do
            colour = state_expectation[:colour]
            expected_tag_class = ".govuk-tag"
            expected_tag_class = "#{expected_tag_class}--#{colour}" if colour.present?

            expect(rendered_content).to have_selector(expected_tag_class)
          end
        end
      end
    end

    context "when a trainee with all their details filled in" do
      let(:state) { "draft" }
      let(:trainee) do
        create(
          :trainee,
          first_names: "Teddy",
          last_name: "Smith",
          course_subject_one: "Design",
          training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
          provider_trainee_id: "132456",
          trn: "789456",
          trainee_start_date: DateTime.new(2020, 1, 2),
          end_academic_cycle: cycle,
          provider: provider,
          state: state,
        )
      end

      before do
        render_inline(described_class.new(record: trainee, current_user: current_user))
      end

      it "does not render provider name" do
        expect(rendered_content).not_to have_css(".application-record-card__provider_name")
      end

      context "when system admin user" do
        let(:current_user) do
          double(UserWithOrganisationContext, system_admin?: true, lead_partner?: false)
        end

        it "renders provider name" do
          expect(rendered_content).to have_css(".application-record-card__provider_name", text: provider.name_and_code)
        end
      end

      it "renders trainee ID" do
        expect(rendered_content).to have_text("Trainee ID: 132456")
      end

      it "renders trn" do
        expect(rendered_content).to have_text("TRN: 789456")
      end

      it "renders start_year" do
        expect(rendered_content).to have_text("Start year: 2019 to 2020")
      end

      it "renders end_year" do
        expect(rendered_content).to have_text("End year: 2019 to 2020")
      end

      it "renders trainee name" do
        expect(rendered_content).to have_text("Teddy Smith")
      end

      it "renders subject" do
        expect(rendered_content).to have_text("Design")
      end

      it "renders route" do
        expect(rendered_content).to have_text(t("activerecord.attributes.trainee.training_routes.assessment_only"))
      end

      describe "rendering updated at" do
        context "when the trainee is in draft" do
          it "renders updated at from the model" do
            expect(rendered_content).to have_text("Updated: #{trainee.created_at.strftime('%-d %B %Y')}")
          end
        end

        context "when the trainee is not draft" do
          let(:state) { "trn_received" }

          it "renders updated at from the timeline" do
            expect(rendered_content).to have_text("Updated: #{Time.zone.now.strftime('%-d %B %Y')}")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe HomeView do
  include Rails.application.routes.url_helpers

  let(:current_user) { create(:user, :system_admin) }
  let(:draft_trainee) { create(:trainee, :draft) }
  let!(:current_academic_cycle) { create(:academic_cycle, :current) }
  let(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }

  subject { described_class.new(trainees, current_user) }

  before do
    allow(Trainees::SetAcademicCycles).to receive(:call) # deactivate so it doesn't override factories
  end

  describe "#action_badges" do
    let(:trainees) do
      trainee_ids = create_list(:abstract_trainee, 2).pluck(:id)

      Trainee.where(id: trainee_ids)
    end

    context "when current_user is a system_admin user" do
      let(:current_user) do
        UserWithOrganisationContext.new(user: create(:user, :system_admin), session: {})
      end

      it "returns nil" do
        expect(subject.action_badges).to be_nil
      end
    end

    context "when current_user is a lead_partner user" do
      let(:current_user) do
        UserWithOrganisationContext.new(user: create(:user, :with_lead_partner_organisation), session: {})
      end

      it "returns nil" do
        expect(subject.action_badges).to be_nil
      end
    end

    context "when current_user is non system_admin user or non lead_partner user" do
      let(:current_user) do
        UserWithOrganisationContext.new(user: create(:user), session: {})
      end

      it "returns nil" do
        expect(subject.action_badges.map(&:to_h)).to eq([
          {
            status: :can_bulk_recommend_for_award,
            trainee_count: 0,
            link: "/bulk-update/recommend/choose-who-to-recommend",
          },
          {
            status: :can_complete,
            trainee_count: 0,
            link: "/trainees?record_completion%5B%5D=incomplete",
          },
        ])
      end
    end
  end

  describe "#badges" do
    let(:not_started_trainee) { create(:trainee, :trn_received, itt_start_date: current_academic_cycle.end_date + 2.months) }
    let(:in_training_trainees) { create_list(:trainee, 2, :trn_received) }
    let(:awarded_this_year_trainee) { create(:trainee, :awarded, end_academic_cycle: current_academic_cycle) }
    let(:awarded_last_year_trainee) { create(:trainee, :awarded, end_academic_cycle: previous_academic_cycle) }
    let(:deferred_trainees) { create_list(:trainee, 2, :deferred) }
    let(:incomplete_trainee) { create(:trainee, :trn_received, :incomplete) }

    let(:trainees) do
      trainee_ids = [
        not_started_trainee.id,
        awarded_this_year_trainee.id,
        awarded_last_year_trainee.id,
        incomplete_trainee.id,
      ] + in_training_trainees.pluck(:id) + deferred_trainees.pluck(:id)

      Trainee.where(id: trainee_ids)
    end

    before do
      allow(Trainee).to receive_message_chain(:course_not_yet_started, :size).and_return(1)
    end

    it "returns correct counts and links" do
      expect(subject.badges.map(&:to_h)).to eq(
        [
          {
            status: :course_not_started_yet,
            trainee_count: 1,
            link: trainees_path(status: %w[course_not_yet_started]),
          },
          # Both the in training trainees plus the incomplete one.
          {
            status: :in_training,
            trainee_count: 3,
            link: trainees_path(status: %w[in_training]),
          },
          {
            status: :awarded_this_year,
            trainee_count: 1,
            link: trainees_path(
              status: %w[awarded],
              end_year: current_academic_cycle.label,
            ),
          },
          {
            status: :deferred,
            trainee_count: 2,
            link: trainees_path(status: %w[deferred]),
          },
          {
            status: :incomplete,
            trainee_count: 1,
            link: trainees_path(record_completion: %w[incomplete]),
          },
        ],
      )
    end
  end

  describe "#draft_trainees_count" do
    let(:trainees) do
      trainee_ids = [
        draft_trainee.id,
        create(:trainee, :assessment_only, :awarded).id,
        create(:trainee, :early_years_undergrad, :awarded).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "returns the number of trainees in draft states" do
      expect(subject.draft_trainees_count).to eq(1)
    end

    context "with empty trainee exists" do
      let(:trainees) do
        trainee_ids = [
          draft_trainee.id,
          Trainee.create!(provider: draft_trainee.provider, training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name).id,
        ]
        Trainee.where(id: trainee_ids)
      end

      it "does not include empty trainees" do
        expect(subject.draft_trainees_count).to eq(1)
      end
    end
  end

  describe "#draft_apply_trainees_count" do
    let(:trainees) do
      trainee_ids = [
        draft_trainee.id,
        create(:trainee, :draft, :with_apply_application).id,
        create(:trainee, :awarded, :with_apply_application).id,
      ]
      Trainee.where(id: trainee_ids)
    end

    it "returns the number of trainees in apply draft states" do
      expect(subject.draft_apply_trainees_count).to eq(1)
    end
  end

  describe "#apply_drafts_link_text" do
    context "when all draft trainees are apply drafts" do
      let(:trainees) do
        trainee_ids = [
          create(:trainee, :draft, :with_apply_application).id,
        ]
        Trainee.where(id: trainee_ids)
      end

      it "returns the correct text" do
        expect(subject.apply_drafts_link_text).to eq(
          I18n.t("landing_page.home.draft_apply_trainees_link_all_apply", count: 1),
        )
      end
    end

    context "when not all draft trainees are apply drafts" do
      let(:trainees) do
        trainee_ids = [
          create(:trainee, :draft).id,
          create(:trainee, :draft, :with_apply_application).id,
        ]
        Trainee.where(id: trainee_ids)
      end

      it "returns the correct text" do
        expect(subject.apply_drafts_link_text).to eq(
          I18n.t("landing_page.home.draft_apply_trainees_link", count: 1, total: 2),
        )
      end
    end
  end
end

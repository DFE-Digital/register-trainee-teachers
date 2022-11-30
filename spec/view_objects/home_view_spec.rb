# frozen_string_literal: true

require "rails_helper"

describe HomeView do
  include Rails.application.routes.url_helpers

  let(:draft_trainee) { create(:trainee, :draft) }
  let!(:current_academic_cycle) { create(:academic_cycle, :current) }
  let(:previous_academic_cycle) { create(:academic_cycle, previous_cycle: true) }

  subject { described_class.new(trainees) }

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
      allow(Trainee).to receive_message_chain(:course_not_yet_started, :count).and_return(1)
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
          Trainee.create!(provider: draft_trainee.provider, training_route: TRAINING_ROUTE_ENUMS[:assessment_only]).id,
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
          I18n.t("pages.home.draft_apply_trainees_link_all_apply", count: 1),
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
          I18n.t("pages.home.draft_apply_trainees_link", count: 1, total: 2),
        )
      end
    end
  end

  context "when there trainees in various states" do
    let(:not_started_trainee) { create_list(:trainee, 3, :trn_received, itt_start_date: current_academic_cycle.end_date + 2.months) }
    let(:in_training_trainees) { create_list(:trainee, 6, :trn_received) }
    let(:awarded_this_year_trainee) { create_list(:trainee, 5, :awarded, end_academic_cycle: current_academic_cycle) }
    let(:awarded_last_year_trainee) { create_list(:trainee, 2, :awarded, end_academic_cycle: previous_academic_cycle) }
    let(:deferred_trainees) { create_list(:trainee, 4, :deferred) }
    let(:incomplete_trainee) { create(:trainee, :trn_received, :incomplete) }

    let(:trainees) do
      trainee_ids = [
        not_started_trainee.pluck(:id),
        awarded_this_year_trainee.pluck(:id),
        awarded_last_year_trainee.pluck(:id),
        incomplete_trainee.id,
        in_training_trainees.pluck(:id),
        deferred_trainees.pluck(:id),
      ].flatten

      Trainee.where(id: trainee_ids)
    end

    describe "#awarded_this_year_size" do
      it "returns the same value as the #count of the ::awarded.merge(current_academic_cycle.trainees_ending) scope" do
        expect(subject.send(:awarded_this_year_size)).to eq(Trainee.awarded.merge(current_academic_cycle.trainees_ending).count)
      end
    end

    describe "#course_not_yet_started_size" do
      it "returns the same value as the #count of the ::course_not_yet_started scope" do
        expect(subject.send(:course_not_yet_started_size)).to eq(Trainee.course_not_yet_started.count)
      end
    end

    describe "#deferred_size" do
      it "returns the same value as the #count of the ::deferred scope" do
        expect(subject.send(:deferred_size)).to eq(Trainee.deferred.count)
      end
    end

    describe "#draft_apply_trainees_count" do
      it "returns the same value as the #count of the ::draft and ::with_apply_application scopes" do
        expect(subject.send(:draft_apply_trainees_count)).to eq(Trainee.draft.with_apply_application.count)
      end
    end

    describe "#draft_trainees_count" do
      it "returns the same value as the #count of the ::draft scope" do
        expect(subject.send(:draft_trainees_count)).to eq(Trainee.draft.count)
      end
    end

    describe "#incomplete_size" do
      it "returns the same value as the #count of the ::not_draft and ::incomplete_for_filter scopes" do
        expect(subject.send(:incomplete_size)).to eq(Trainee.not_draft.incomplete_for_filter.count)
      end
    end

    describe "#trainees_in_training_size" do
      it "returns the same value as the #count of the ::in_training scope" do
        expect(subject.send(:trainees_in_training_size)).to eq(Trainee.in_training.count)
      end
    end
  end
end

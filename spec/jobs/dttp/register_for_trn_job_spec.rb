# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RegisterForTrnJob do
    let(:trainee) { create(:trainee, dttp_id: dttp_id, placement_assignment_dttp_id: placement_assignment_dttp_id) }
    let(:dttp_id) { SecureRandom.uuid }
    let(:placement_assignment_dttp_id) { SecureRandom.uuid }
    let(:creator_dttp_id) { SecureRandom.uuid }
    let(:run_date) { "01/08/2021" }

    before do
      enable_features(:persist_to_dttp)

      allow(RegisterForTrn).to receive(:call)
    end

    around do |example|
      Timecop.freeze(run_date) do
        example.run
      end
    end

    describe "#perform_now" do
      subject { described_class.perform_now(trainee, creator_dttp_id) }

      it "registers the trainee" do
        expect(RegisterForTrn).to receive(:call).with(trainee: trainee, created_by_dttp_id: creator_dttp_id)
        subject
      end

      it "queues a job to update the contact status" do
        expect { subject }.to have_enqueued_job(ChangeTraineeStatusJob).with(
          trainee,
          DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
          UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
        )
      end

      it "queues a job to update the placement assignment" do
        expect { subject }.to have_enqueued_job(ChangeTraineeStatusJob).with(
          trainee,
          DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
          UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
        )
      end

      context "for non-AO trainees" do
        let(:clockover_date) { "01/08/2021" }

        before do
          allow(Settings).to receive(:clockover_date).and_return(clockover_date)
        end

        context "before clockover" do
          let(:run_date) { "31/07/2021" }

          context "the trainee is assessment only" do
            before do
              trainee.early_years_assessment_only!
            end

            it "runs the job" do
              expect(RegisterForTrn).to receive(:call).with(trainee: trainee, created_by_dttp_id: creator_dttp_id)
              subject
            end
          end

          context "the trainee is not assessment only" do
            before do
              trainee.provider_led_postgrad!
            end

            it "requeues the job for after clockover" do
              expect(RegisterForTrnJob).to receive(:set).with(wait_until: Time.zone.parse(clockover_date)).and_return(job = double)
              expect(job).to receive(:perform_later).with(trainee, creator_dttp_id)
              subject
            end

            it "does not make the request to DTTP" do
              expect(RegisterForTrn).not_to receive(:call)
              subject
            end
          end
        end
      end
    end
  end
end

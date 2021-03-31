# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimelineEvents do
    let(:trainee) { create(:trainee) }

    subject { described_class.call(audits: trainee.audits) }

    describe "#call" do
      shared_examples "created" do
        it "returns a trainee created event" do
          event = subject.last
          expect(event.title).to eq(t("components.timeline.titles.created"))
        end
      end

      shared_examples "updated" do
        it "returns a timeline event the reflects the update" do
          event = subject[-2]
          expect(event.title).to eq("Trainee first names updated")
        end
      end

      context "when a trainee is just created" do
        include_examples "created"
      end

      context "when a trainee field is updated" do
        before do
          trainee.update!(first_names: "name")
        end

        include_examples "created"
        include_examples "updated"
      end

      context "when a trainee field is updated and then the state is changed" do
        before do
          trainee.update!(first_names: "name")
          trainee.submit_for_trn!
        end

        include_examples "created"
        include_examples "updated"

        it "returns a state change timeline event" do
          expect(subject.first.title).to eq(t("components.timeline.titles.submitted_for_trn"))
        end
      end
    end
  end
end

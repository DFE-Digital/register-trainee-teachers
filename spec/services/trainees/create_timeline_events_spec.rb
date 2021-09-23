# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimelineEvents do
    let(:system_admin) { create(:user, :system_admin) }
    let(:provider_user) { create(:user) }
    let(:trainee) { create(:trainee, awarded_at: Time.zone.now) }

    subject { described_class.call(audit: trainee.own_and_associated_audits.first) }

    describe "#call" do
      context "with a trainee creation audit" do
        it "returns a trainee created event" do
          expect(subject.title).to eq(t("components.timeline.titles.trainee.create"))
        end
      end

      context "with a trainee update audit" do
        before do
          trainee.update!(first_names: "name")
        end

        context "made by a provider user" do
          before do
            trainee.own_and_associated_audits.first.update(user: provider_user)
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated")
          end

          it "returns a timeline event with the user's name" do
            expect(subject.first.username).to eq(provider_user.name)
          end
        end

        context "made by a system admin" do
          before do
            trainee.own_and_associated_audits.first.update(user: system_admin)
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated")
          end

          it "returns a timeline event obscuring the admin's name" do
            expect(subject.first.username).to eq("DfE administrator")
          end
        end
      end

      context "with a trainee state change audit" do
        before do
          trainee.submit_for_trn!
        end

        it "returns a 'state change' timeline event" do
          expect(subject.title).to eq(t("components.timeline.titles.trainee.submitted_for_trn"))
        end
      end

      context "with a `recommended_for_award` state change audit" do
        before do
          %i[submit_for_trn! receive_trn! recommend_for_award!].each { |m| trainee.public_send(m) }
        end

        context "with a QTS trainee" do
          it "returns a 'Recommended for QTS' timeline event" do
            expect(subject.title).to eq(t("components.timeline.titles.trainee.recommended_for_qts"))
          end
        end

        context "with an EYTS trainee" do
          let(:trainee) { create(:trainee, :early_years_undergrad) }

          it "returns a 'Recommended for EYTS' timeline event" do
            expect(subject.title).to eq(t("components.timeline.titles.trainee.recommended_for_eyts"))
          end
        end
      end

      context "with an `awarded` state change audit" do
        before do
          %i[submit_for_trn! receive_trn! recommend_for_award! award!].each { |m| trainee.public_send(m) }
        end

        context "with a QTS trainee" do
          it "returns a 'QTS awarded' timeline event" do
            expect(subject.title).to eq(t("components.timeline.titles.trainee.qts_awarded"))
          end
        end

        context "with an EYTS trainee" do
          let(:trainee) { create(:trainee, :early_years_undergrad, awarded_at: Time.zone.now) }

          it "returns a 'EYTS awarded' timeline event" do
            expect(subject.title).to eq(t("components.timeline.titles.trainee.eyts_awarded"))
          end
        end
      end

      context "with an associated audit" do
        let(:degree) { create(:degree, trainee: trainee) }

        it "returns a 'creation' timeline event" do
          degree.reload
          expect(subject.title).to eq(t("components.timeline.titles.degree.create"))
        end
      end

      context "with a destroy associated audit" do
        let(:degree) { create(:degree, trainee: trainee) }

        before do
          degree.reload
          trainee.degrees.first.destroy!
        end

        it "returns a 'destroyed' timeline event" do
          expect(subject.title).to eq(t("components.timeline.titles.degree.destroy"))
        end
      end

      context "with a no-change audit" do
        before do
          trainee.update!(middle_names: nil)
          trainee.update!(middle_names: "")
        end

        it "returns empty timeline event" do
          expect(subject).to eq [nil]
        end
      end
    end
  end
end

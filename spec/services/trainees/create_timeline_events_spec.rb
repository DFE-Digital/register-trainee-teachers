# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimelineEvents do
    let(:system_admin) { create(:user, :system_admin) }
    let(:provider_user) { create(:user) }
    let(:current_user) { nil }
    let(:trainee) { create(:trainee, awarded_at: Time.zone.now) }

    subject { described_class.call(audit: trainee.own_and_associated_audits.first, current_user: current_user) }

    describe "#call" do
      context "with a trainee creation audit" do
        it "returns a trainee created event" do
          expect(subject.first.title).to eq("Record created")
        end

        context "when the creation audit was from a DTTP or HESA import" do
          before do
            trainee.own_and_associated_audits.first.update!(user: "HESA")
          end

          it "returns an array including a creation timeline event with that user in the title" do
            expect(subject.first.title).to eq("Record created in HESA")
          end

          it "returns an array including an import event" do
            expect(subject.last.title).to eq("Record imported from HESA")
          end
        end

        context "when the audit was created after the model instance was created" do
          let(:trainee_created_at) { Time.zone.yesterday }

          before do
            trainee.update!(created_at: trainee_created_at)
          end

          it "returns a timeline event with the earlier created_at" do
            expect(subject.first.date).to eq(trainee_created_at)
          end
        end
      end

      context "with a trainee update audit" do
        before do
          trainee.update!(first_names: "name")
        end

        context "made by a provider user" do
          before do
            trainee.own_and_associated_audits.first.update!(user: provider_user)
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated")
          end

          context "and there's no current_user set" do
            it "returns a timeline event with the provider's name" do
              expect(subject.first.username).to eq(trainee.provider.name_and_code)
            end
          end

          context "and there's a current_user different to the audit's user" do
            let(:current_user) { create(:user) }

            it "returns a timeline event with the provider's name" do
              expect(subject.first.username).to eq(trainee.provider.name_and_code)
            end
          end

          context "and there's a current_user the same as the audit's user" do
            let(:current_user) { provider_user }

            it "returns a timeline event with the user's name" do
              expect(subject.first.username).to eq(provider_user.name)
            end
          end

          context "and the current_user is a system admin" do
            let(:current_user) { create(:user, :system_admin) }

            it "returns a timeline event with the user's name and the provider's name" do
              expect(subject.first.username).to eq("#{provider_user.name} (#{trainee.provider.name_and_code})")
            end
          end
        end

        context "made by a system admin" do
          before do
            trainee.own_and_associated_audits.first.update!(user: system_admin)
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated")
          end

          it "returns a timeline event obscuring the admin's name" do
            expect(subject.first.username).to eq("DfE administrator")
          end
        end

        context "with a provider user" do
          let(:provider) { create(:provider, name: "South Oxfordshire Academy") }

          before do
            trainee.own_and_associated_audits.first.update!(user: provider)
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated")
          end

          it "returns a timeline event with the provider name and indicating that it happened via the API" do
            expect(subject.first.username).to eq("South Oxfordshire Academy (via Register API)")
          end
        end

        context "made in HESA" do
          before do
            trainee.own_and_associated_audits.first.update!(username: "HESA")
          end

          it "returns a timeline event that reflects the update" do
            expect(subject.first.title).to eq("First names updated in HESA")
          end

          it "returns a timeline event with no name" do
            expect(subject.first.username).to be_nil
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

      context "with an associated degree" do
        let(:degree) { create(:degree, trainee:) }
        let(:associated_audit) do
          trainee.own_and_associated_audits.includes(%i[user auditable]).find { |a| a.auditable_type == "Degree" }
        end

        subject { described_class.call(audit: associated_audit, current_user: current_user) }

        it "returns a 'creation' timeline event" do
          degree.reload

          expect(subject.first.title).to eq(t("components.timeline.titles.degree.create"))
        end

        context "when imported from dttp" do
          before do
            degree.save!
            associated_audit.update!(user: "DTTP")
          end

          it "returns empty timeline event" do
            expect(subject).to be_nil
          end
        end
      end

      context "with an associated placement" do
        let(:placement) { create(:placement, trainee:) }
        let(:associated_audit) do
          trainee.own_and_associated_audits.where(auditable_type: "Placement").last
        end

        subject { described_class.call(audit: associated_audit, current_user: current_user) }

        context "for a create action" do
          it "returns a 'creation' timeline event" do
            placement.reload

            expect(GetPlacementNameFromAudit).to receive(:call).with(audit: associated_audit).once.and_call_original

            expect(subject.first.title).to eq("Placement at #{placement.name} added")
          end
        end

        context "for an update action" do
          let(:placement) { create(:placement, trainee:) }
          let(:associated_audit) do
            trainee.own_and_associated_audits.where(auditable_type: "Placement", action: :update).last
          end

          context "update name" do
            it "returns an 'update' timeline event" do
              original_name = placement.name
              placement.update!(name: "University of South Oxfordshire")
              placement.reload

              expect(GetPlacementNameFromAudit).to receive(:call).with(audit: associated_audit).once.and_call_original

              expect(subject.title).to eq("Placement changed from #{original_name} to University of South Oxfordshire")
            end
          end

          context "update postcode" do
            it "returns empty timeline event" do
              placement.update!(postcode: "BN1 1AA")
              placement.reload

              expect(GetPlacementNameFromAudit).not_to receive(:call)

              expect(subject).to be_empty
            end
          end

          context "update urn" do
            it "returns empty timeline event" do
              placement.update!(urn: "100000")
              placement.reload

              expect(GetPlacementNameFromAudit).not_to receive(:call)

              expect(subject).to be_empty
            end
          end
        end

        context "for a destroy action" do
          let(:associated_audit) do
            trainee.own_and_associated_audits.where(auditable_type: "Placement", action: :destroy).last
          end

          it "returns a 'removed' timeline event" do
            placement.destroy!

            expect(GetPlacementNameFromAudit).to receive(:call).with(audit: associated_audit).once.and_call_original

            expect(subject.title).to eq("Placement at #{placement.name} removed")
          end
        end
      end

      context "with a destroy associated audit" do
        let(:degree) { create(:degree, trainee:) }

        before do
          degree.reload

          trainee.reload.degrees.first.destroy!
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
          expect(subject).to be_empty
        end
      end

      context "with an accredited provider change" do
        let(:new_provider) { create(:provider) }

        before do
          @old_provider = trainee.provider
          trainee.update!(provider: new_provider, audit_comment: "Original provider has stopped teaching")
        end

        it "title indicates an accredited provider update event" do
          expect(subject.title).to eq("Accredited provider changed from #{@old_provider.name_and_code} to #{new_provider.name_and_code}")
        end

        it "item includes the audit comment" do
          expect(subject.items).to eq(["Original provider has stopped teaching"])
        end
      end
    end
  end
end

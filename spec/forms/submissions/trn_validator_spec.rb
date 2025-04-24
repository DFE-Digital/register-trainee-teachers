# frozen_string_literal: true

require "rails_helper"

module Submissions
  describe TrnValidator, type: :model do
    let(:trainee) do
      create(
        :trainee,
        :completed,
        progress:,
      )
    end

    shared_examples "error" do
      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors).not_to be_empty
      end
    end

    describe "validations" do
      context "when all sections are valid and complete" do
        subject { described_class.new(trainee:) }

        let(:progress) do
          {
            degrees: true,
            diversity: true,
            contact_details: true,
            personal_details: true,
            course_details: true,
            training_details: true,
            lead_partner_and_employing_school_details: true,
            funding: true,
            placements: true,
          }
        end

        it "is valid" do
          expect(subject.valid?).to be true
          expect(subject.errors).to be_empty
        end

        context "requires school" do
          context "trainee is on the school_direct_tuition_fee route" do
            context "with lead and employing schools" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :with_lead_partner,
                  :with_employing_school,
                  :with_placements,
                  :completed,
                  progress: progress.merge(schools: true),
                )
              end

              it "is valid" do
                expect(subject).to be_valid
              end
            end

            context "with no lead and employing school" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :completed,
                  progress: progress.merge(schools: true),
                )
              end

              it "is invalid" do
                expect(subject.valid?).to be false
                expect(subject.errors).not_to be_empty
              end
            end

            context "with only employing school" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :with_employing_school,
                  :completed,
                  progress: progress.merge(schools: true),
                )
              end

              it "is invalid" do
                expect(subject.valid?).to be false
                expect(subject.errors).not_to be_empty
              end
            end

            context "with only lead school" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :with_lead_partner,
                  :with_placements,
                  :completed,
                  progress: progress.merge(schools: true),
                )
              end

              it "is valid" do
                expect(subject).to be_valid
              end
            end
          end

          %i[school_direct_salaried pg_teaching_apprenticeship].each do |route|
            context "trainee is on the #{route} route" do
              context "with lead and employing schools" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :with_lead_partner,
                    :with_employing_school,
                    :completed,
                    :with_placements,
                    progress: progress.merge(schools: true),
                  )
                end

                it "is valid" do
                  expect(subject).to be_valid
                end
              end

              context "with no lead and employing school" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :completed,
                    progress: progress.merge(schools: true),
                  )
                end

                it "is invalid" do
                  expect(subject.valid?).to be false
                  expect(subject.errors).not_to be_empty
                end
              end

              context "with only employing school" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :with_employing_school,
                    :completed,
                    progress: progress.merge(schools: true),
                  )
                end

                it "is invalid" do
                  expect(subject.valid?).to be false
                  expect(subject.errors.messages).to include({ schools: ["Schools not marked as complete"] })
                end
              end

              context "with only lead school" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :with_lead_partner,
                    :completed,
                    progress: progress.merge(schools: true),
                  )
                end

                it "is invalid" do
                  expect(subject.valid?).to be false
                  expect(subject.errors.messages).to include({ schools: ["Schools not marked as complete"] })
                end
              end
            end
          end
        end

        context "apply application" do
          let(:trainee) do
            create(
              :trainee,
              :completed,
              :with_apply_application,
              progress: progress.merge(trainee_data: true),
            )
          end

          it "is valid" do
            expect(subject.valid?).to be true
            expect(subject.errors).to be_empty
          end

          context "without placements" do
            let(:trainee) do
              create(
                :trainee,
                :completed,
                :with_apply_application,
                :early_years_postgrad,
                progress: progress.merge(trainee_data: true, placements: false),
              )
            end

            it "is not valid" do
              expect(subject).not_to be_valid
            end
          end
        end
      end

      context "when any section is invalid or incomplete" do
        subject { described_class.new(trainee:) }

        let(:progress) do
          {
            degrees: nil,
            diversity: false,
            contact_details: true,
            personal_details: true,
            course_details: true,
            training_details: true,
          }
        end

        it_behaves_like "error"

        context "requires school but incomplete" do
          let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_partner, progress: progress.merge(schools: false)) }

          it_behaves_like "error"
        end
      end

      context "with empty progress" do
        subject { described_class.new(trainee:) }

        let(:progress) { {} }

        it_behaves_like "error"
      end

      context "with incomplete trainee" do
        let(:trainee) { build(:trainee, :incomplete_draft) }
        let(:progress) { {} }

        subject { described_class.new(trainee:) }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages).to include(
            { personal_details: ["Personal details not marked as complete"],
              contact_details: ["Contact details not marked as complete"],
              diversity: ["Diversity information not marked as complete"],
              degrees: ["Degree details not started"],
              course_details: ["Course details not started"],
              training_details: ["Trainee ID not marked as complete"],
              funding: ["Funding details cannot be started yet"] },
          )
        end
      end
    end

    describe "#all_sections_complete?" do
      subject { described_class.new(trainee:) }

      context "when trainee is non draft" do
        let(:trainee) { build(:trainee, :completed, :trn_received) }

        it "returns true" do
          expect(subject.all_sections_complete?).to be(true)
        end
      end

      context "when trainee is incomplete draft" do
        let(:trainee) { build(:trainee, :incomplete_draft) }

        it "returns false" do
          expect(subject.all_sections_complete?).to be(false)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionForm, type: :model do
  let(:trainee) do
    create(
      :trainee,
      :completed,
      progress: progress,
    )
  end

  shared_examples "error" do
    it "is invalid and returns an error message" do
      expect(subject.valid?).to be false
      expect(subject.errors.messages[:trainee]).to include(I18n.t("activemodel.errors.models.trn_submission_form.attributes.trainee.incomplete"))
    end
  end

  describe "validations" do
    context "when all sections are valid and complete" do
      subject { described_class.new(trainee: trainee) }

      let(:progress) do
        {
          degrees: true,
          diversity: true,
          contact_details: true,
          personal_details: true,
          course_details: true,
          training_details: true,
          funding: true,
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
                :with_lead_school,
                :with_employing_school,
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
                :with_lead_school,
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
                  :with_lead_school,
                  :with_employing_school,
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
                expect(subject.errors).not_to be_empty
              end
            end

            context "with only lead school" do
              let(:trainee) do
                create(
                  :trainee,
                  route,
                  :with_lead_school,
                  :completed,
                  progress: progress.merge(schools: true),
                )
              end

              it "is invalid" do
                expect(subject.valid?).to be false
                expect(subject.errors).not_to be_empty
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
      end
    end

    context "when any section is invalid or incomplete" do
      subject { described_class.new(trainee: trainee) }

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

      include_examples "error"

      context "requires school but incomplete" do
        let(:trainee) { create(:trainee, :school_direct_salaried, :with_lead_school, progress: progress.merge(schools: false)) }

        include_examples "error"
      end
    end

    context "with empty progress" do
      subject { described_class.new(trainee: trainee) }

      let(:progress) { {} }

      include_examples "error"
    end
  end
end

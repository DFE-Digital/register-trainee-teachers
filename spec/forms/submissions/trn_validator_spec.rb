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
            training_partner_and_employing_school_details: true,
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
            context "with training partner and employing schools" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :with_training_partner,
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

            context "with no training partner and employing school" do
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

            context "with only training partner" do
              let(:trainee) do
                create(
                  :trainee,
                  :school_direct_tuition_fee,
                  :with_training_partner,
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
              context "with training partner and employing schools" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :with_training_partner,
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

              context "with no training partner and employing school" do
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

              context "with only training partner" do
                let(:trainee) do
                  create(
                    :trainee,
                    route,
                    :with_training_partner,
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
          let(:trainee) { create(:trainee, :school_direct_salaried, :with_training_partner, progress: progress.merge(schools: false)) }

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

    describe "funding that needs the degree first" do
      let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
      let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
      let(:trainee) do
        create(:trainee, :provider_led_postgrad, course_allocation_subject: mathematics, start_academic_cycle: cycle,
                                                 progress: Progress.new(course_details: true))
      end

      subject { described_class.new(trainee:) }

      before do
        enable_features(:funding_eligibility_step)
        trainee.degrees.destroy_all
        funding_method = create(:funding_method, training_route: trainee.training_route, academic_cycle: cycle, degree_relevance: :relevant)
        create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
      end

      it "lists the funding message" do
        expect(subject).not_to be_valid
        expect(subject.errors[:funding]).to eq(["Funding for this route requires the previous degree to be completed first"])
      end
    end

    describe "funding to be confirmed again after the employing school changed" do
      let(:trainee) do
        create(:trainee, :school_direct_salaried, :with_employing_school, start_academic_cycle: AcademicCycle.current || create(:academic_cycle, :current),
                                                                          progress: Progress.new(course_details: true, funding: false, funding_recheck_employing_school: true))
      end

      subject { described_class.new(trainee:) }

      before { enable_features(:funding_eligibility_step) }

      it "lists the funding message" do
        expect(subject).not_to be_valid
        expect(subject.errors[:funding]).to eq(["Funding needs to be confirmed again because the employing school changed"])
      end
    end

    describe "the employing school to be confirmed again after the course details changed" do
      let(:trainee) do
        create(:trainee, :school_direct_salaried, :with_employing_school, start_academic_cycle: AcademicCycle.current || create(:academic_cycle, :current),
                                                                          progress: Progress.new(course_details: true, schools: false, schools_recheck_course_details: true))
      end

      subject { described_class.new(trainee:) }

      before { enable_features(:funding_eligibility_step) }

      it "lists the message" do
        expect(subject).not_to be_valid
        expect(subject.errors[:schools]).to eq(["Training partner and employing school needs to be confirmed again because the course details changed"])
      end
    end

    describe "the level 5 declaration" do
      subject { described_class.new(trainee:) }

      context "for an EYTDA trainee" do
        let(:trainee) { create(:trainee, :early_years_teacher_degree_apprenticeship) }

        it "is needed for a TRN" do
          expect(subject).not_to be_valid
          expect(subject.errors[:level_five_declaration]).to eq(["Level 5 declaration not started"])
        end
      end

      context "for another route" do
        let(:trainee) { create(:trainee, :provider_led_postgrad) }

        it "isn't asked" do
          subject.valid?
          expect(subject.errors[:level_five_declaration]).to be_empty
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

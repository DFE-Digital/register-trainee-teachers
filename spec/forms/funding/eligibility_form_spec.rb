# frozen_string_literal: true

require "rails_helper"

module Funding
  describe EligibilityForm, feature_funding_eligibility_step: true, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, funding_eligibility: "eligible") }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:funding_eligibility) }
      it { is_expected.to validate_inclusion_of(:funding_eligibility).in_array(FUNDING_ELIGIBILITIES.values) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee ID and funding_eligibility" do
        expect(form_store).to receive(:set).with(trainee.id, :funding_eligibility, subject.fields)

        subject.stash
      end
    end

    describe "#save!" do
      let(:eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

      before do
        allow(form_store).to receive(:get).and_return({ "funding_eligibility" => eligibility })
        allow(form_store).to receive(:set).with(trainee.id, :funding_eligibility, nil)
      end

      it "takes any data from the form store and saves it to the database" do
        expect { subject.save! }.to change(trainee, :funding_eligibility).to(eligibility)
      end

      context "when funding eligibility is eligible" do
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 applying_for_bursary: true,
                 applying_for_scholarship: false,
                 applying_for_grant: true,
                 bursary_tier: :tier_one)
        end
        let(:eligibility) { FUNDING_ELIGIBILITIES[:eligible] }

        it "preserves the funding method fields" do
          subject.save!

          expect(trainee.reload).to have_attributes(
            applying_for_bursary: true,
            applying_for_scholarship: false,
            applying_for_grant: true,
            bursary_tier: "tier_one",
          )
        end
      end

      context "when funding eligibility changes to not eligible and the trainee is not in the fund-code exception list" do
        let(:academic_cycle) { create(:academic_cycle, :current, published: true) }
        let(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::BIOLOGY) }
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 course_allocation_subject: allocation_subject,
                 start_academic_cycle: academic_cycle,
                 applying_for_bursary: true,
                 applying_for_scholarship: false,
                 applying_for_grant: true,
                 bursary_tier: :tier_one)
        end
        let(:eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

        it "clears the funding method fields" do
          subject.save!

          expect(trainee.reload).to have_attributes(
            applying_for_bursary: nil,
            applying_for_scholarship: nil,
            applying_for_grant: nil,
            bursary_tier: nil,
          )
        end

        context "and the trainee has a hesa_trainee_detail with funding_method set" do
          before do
            trainee.create_hesa_trainee_detail!(funding_method: Hesa::CodeSets::BursaryLevels::TIER_ONE)
          end

          it "syncs hesa_trainee_detail.funding_method to NONE" do
            subject.save!

            expect(trainee.reload.hesa_trainee_detail.funding_method)
              .to eq(Hesa::CodeSets::BursaryLevels::NONE)
          end
        end
      end

      context "when funding eligibility changes to not eligible but the trainee is in the fund-code exception list" do
        # The exception only covers trainees starting in 2025 to 2026 or 2026 to 2027.
        let(:academic_cycle) do
          AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31))
        end
        let(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::PHYSICS) }
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 course_allocation_subject: allocation_subject,
                 start_academic_cycle: academic_cycle,
                 itt_start_date: Date.new(2026, 9, 1),
                 trainee_start_date: Date.new(2026, 9, 1),
                 applying_for_bursary: true,
                 bursary_tier: :tier_one)
        end
        let(:eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

        it "preserves the funding method fields" do
          subject.save!

          expect(trainee.reload).to have_attributes(
            applying_for_bursary: true,
            bursary_tier: "tier_one",
          )
        end
      end
    end

    describe "the grant question (early years postgraduate)" do
      let(:academic_cycle) { create(:academic_cycle, :current, published: true) }
      let(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }
      let(:trainee) do
        create(:trainee,
               training_route: :early_years_postgrad,
               funding_eligibility: "eligible",
               course_allocation_subject: allocation_subject,
               start_academic_cycle: academic_cycle)
      end

      before { allow(form_store).to receive(:set) }

      context "when a grant genuinely exists for the route" do
        before do
          funding_method = create(:funding_method, :grant, training_route: :early_years_postgrad, amount: 7_000, academic_cycle: academic_cycle)
          create(:funding_method_subject, funding_method:, allocation_subject:)
        end

        it "requires the grant question to be answered" do
          form = described_class.new(trainee, params: { funding_eligibility: "eligible" }, store: form_store)
          expect(form.grant_question?).to be(true)
          expect(form).not_to be_valid
          expect(form.errors[:custom_applying_for_grant]).to include("Select if the provider should be awarded a grant")
        end

        it "persists applying_for_grant from the answer" do
          form = described_class.new(
            trainee,
            params: { funding_eligibility: "eligible", custom_applying_for_grant: "yes" },
            store: form_store,
          )
          form.save!
          expect(trainee.reload.applying_for_grant).to be(true)
        end
      end

      context "when no grant exists for the route" do
        it "does not require the grant answer and does not persist it" do
          form = described_class.new(
            trainee,
            params: { funding_eligibility: "eligible", custom_applying_for_grant: "yes" },
            store: form_store,
          )
          expect(form.grant_question?).to be(false)
          expect(form).to be_valid
          form.save!
          expect(trainee.reload.applying_for_grant).to be_nil
        end
      end

      context "when the trainee is not eligible" do
        it "does not ask the grant question and clears the grant field" do
          form = described_class.new(trainee, params: { funding_eligibility: "not_eligible" }, store: form_store)
          expect(form.grant_question?).to be(false)
          form.save!
          expect(trainee.reload.applying_for_grant).to be_nil
        end
      end
    end
  end
end

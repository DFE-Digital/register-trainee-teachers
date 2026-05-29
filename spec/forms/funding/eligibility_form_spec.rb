# frozen_string_literal: true

require "rails_helper"

module Funding
  describe EligibilityForm, type: :model do
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
        let(:academic_cycle) { create(:academic_cycle, :current) }
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
      end

      context "when funding eligibility changes to not eligible but the trainee is in the fund-code exception list" do
        let(:academic_cycle) { create(:academic_cycle, :current) }
        let(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::PHYSICS) }
        let(:trainee) do
          create(:trainee,
                 funding_eligibility: "eligible",
                 course_allocation_subject: allocation_subject,
                 start_academic_cycle: academic_cycle,
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
  end
end

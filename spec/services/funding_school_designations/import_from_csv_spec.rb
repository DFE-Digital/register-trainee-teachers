# frozen_string_literal: true

require "rails_helper"

module FundingSchoolDesignations
  describe ImportFromCsv do
    describe "#call" do
      subject(:import) { described_class.call(upload_id: upload.id, academic_cycle: academic_cycle) }

      let(:upload) { create(:upload, fixture_name: "funding_school_designations_import.csv") }
      let(:academic_cycle) { create(:academic_cycle, :current) }
      let!(:disadvantaged_school) { create(:school, urn: "100001") }
      let!(:special_school) { create(:school, urn: "100002") }

      before { create(:school, urn: "100003") }

      it "creates funding school designations for rows with a known URN and a valid designation" do
        expect { import }.to change(FundingSchoolDesignation, :count).by(2)

        expect(
          FundingSchoolDesignation.where(academic_cycle:).pluck(:school_id, :designation),
        ).to contain_exactly(
          [disadvantaged_school.id, "disadvantaged"],
          [special_school.id, "special"],
        )
      end

      it "adds unknown URNs to unmatched_urns" do
        expect(import.unmatched_urns).to contain_exactly("999999")
      end

      it "adds invalid designations to invalid_designations" do
        expect(import.invalid_designations).to contain_exactly("unknown")
      end

      context "when the funding school designations already exist" do
        before do
          create(:funding_school_designation, academic_cycle: academic_cycle, school: disadvantaged_school, designation: "special")
          create(:funding_school_designation, academic_cycle: academic_cycle, school: special_school, designation: "special")
        end

        it "does not create duplicates" do
          expect { import }.not_to change(FundingSchoolDesignation, :count)
        end

        it "does not overwrite an existing designation" do
          import

          expect(disadvantaged_school.funding_school_designations.find_by(academic_cycle:)).to be_special
        end

        it "adds URNs with a different existing designation to conflicting_urns" do
          expect(import.conflicting_urns).to contain_exactly("100001")
        end
      end
    end
  end
end

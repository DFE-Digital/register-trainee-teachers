# frozen_string_literal: true

require "rails_helper"

module RelevantDegreeSubjects
  describe ImportFromCsv do
    describe "#call" do
      subject(:import) { described_class.call(upload_id: upload.id, academic_cycle: academic_cycle) }

      let(:upload) { create(:upload, fixture_name: "relevant_degree_subjects_import.csv") }
      let(:academic_cycle) { create(:academic_cycle, :current) }
      let!(:mathematics) { create(:allocation_subject, name: "Mathematics") }
      let!(:physics) { create(:allocation_subject, name: "Physics") }

      it "creates relevant degree subjects for rows with a known allocation subject and a valid HECOS code" do
        expect { import }.to change(RelevantDegreeSubject, :count).by(3)

        expect(
          RelevantDegreeSubject.where(academic_cycle:).pluck(:allocation_subject_id, :hecos_code),
        ).to contain_exactly(
          [mathematics.id, "100403"],
          [physics.id, "100425"],
          [physics.id, "100417"],
        )
      end

      it "adds unknown allocation subjects to unmatched_allocation_subjects" do
        expect(import.unmatched_allocation_subjects).to contain_exactly("Unknown subject")
      end

      it "adds invalid HECOS codes to invalid_hecos_codes" do
        expect(import.invalid_hecos_codes).to contain_exactly("123456", "999999")
      end

      context "when the relevant degree subjects already exist" do
        before do
          create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: mathematics, hecos_code: "100403")
          create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: physics, hecos_code: "100425")
          create(:relevant_degree_subject, academic_cycle: academic_cycle, allocation_subject: physics, hecos_code: "100417")
        end

        it "does not create duplicates" do
          expect { import }.not_to change(RelevantDegreeSubject, :count)
        end
      end
    end
  end
end

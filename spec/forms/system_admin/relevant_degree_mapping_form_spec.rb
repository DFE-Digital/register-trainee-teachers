# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe RelevantDegreeMappingForm do
    let(:cycle) { create(:academic_cycle, next_cycle: true) }
    # CAH01 → CAH01-01 → HECoS codes (from the reference data)
    let(:hecos) { ::Funding::CahReference.hecos_codes_for("CAH01-01").first(2) }
    let(:valid_params) do
      {
        academic_year: cycle.start_year,
        allocation_subject_id: subject.id,
        cah_level_1_code: "CAH01",
        cah_level_2_code: "CAH01-01",
        hecos_codes: hecos,
      }
    end

    subject { create(:allocation_subject, name: "Biology") }

    it "creates one record per HECoS code, each with a DRCAH reference" do
      form = described_class.new(valid_params)
      expect { form.save! }.to change(RelevantDegreeMapping, :count).by(hecos.size)

      created = form.created_mappings
      expect(created.map(&:hecos_code)).to match_array(hecos)
      expect(created).to all(have_attributes(academic_cycle: cycle, allocation_subject: subject,
                                             cah_level_1_code: "CAH01", cah_level_2_code: "CAH01-01"))
      expect(created.map(&:reference)).to all(match(/\ADRCAH\d{3,}\z/))
    end

    it "numbers references sequentially starting at DRCAH001" do
      described_class.new(valid_params.merge(hecos_codes: [hecos.first])).save!
      expect(RelevantDegreeMapping.first.reference).to eq("DRCAH001")
    end

    it "is invalid without any HECoS codes" do
      form = described_class.new(valid_params.merge(hecos_codes: [""]))
      expect(form.save!).to be(false)
      expect(form.errors[:hecos_codes]).to be_present
    end

    it "rejects HECoS codes that do not belong to the chosen CAH level 2" do
      form = described_class.new(valid_params.merge(hecos_codes: ["999999"]))
      expect(form.save!).to be(false)
      expect(form.errors[:hecos_codes].join).to include("belong to the chosen CAH level 2")
    end

    it "rejects an invalid CAH level 2 for the chosen level 1" do
      form = described_class.new(valid_params.merge(cah_level_2_code: "CAH02-02"))
      expect(form.save!).to be(false)
      expect(form.errors[:cah_level_2_code]).to be_present
    end

    it "cannot change a year that is live or has ended" do
      live = AcademicCycle.current || create(:academic_cycle, :current)
      form = described_class.new(valid_params.merge(academic_year: live.start_year))
      expect(form.save!).to be(false)
      expect(form.errors[:academic_year].join).to include("live or has ended")
    end

    it "rejects HECoS codes already recorded for the subject in the year" do
      described_class.new(valid_params).save!
      dup = described_class.new(valid_params)
      expect(dup.save!).to be(false)
      expect(dup.errors[:base].join).to include("already recorded for this subject and year")
    end
  end
end

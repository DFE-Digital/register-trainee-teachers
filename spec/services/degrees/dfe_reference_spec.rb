# frozen_string_literal: true

require "rails_helper"

module Degrees
  describe DfeReference do
    describe ".find_subject" do
      let(:degree_subject) do
        DfE::ReferenceData::Degrees::SUBJECTS.all.find { |item| item[:hecos_code].present? }
      end

      it "can find the subject by UUID" do
        expect(described_class.find_subject(uuid: degree_subject.id)).to eq(degree_subject)
      end

      it "can find the subject by name" do
        expect(described_class.find_subject(name: degree_subject.name)).to eq(degree_subject)
      end

      it "can find the subject by hecos_code" do
        expect(described_class.find_subject(hecos_code: degree_subject.hecos_code)).to eq(degree_subject)
      end
    end

    describe ".find_type" do
      let(:degree_type) do
        DfE::ReferenceData::Degrees::TYPES_INCLUDING_GENERICS.all.find do |item|
          item[:hesa_itt_code].present? && item[:abbreviation].present?
        end
      end

      it "can find the type by UUID" do
        expect(described_class.find_type(uuid: degree_type.id)).to eq(degree_type)
      end

      it "can find the type by abbreviation" do
        expect(described_class.find_type(abbreviation: degree_type.abbreviation)).to eq(degree_type)
      end

      it "can find the type by HESA code" do
        expect(described_class.find_type(hesa_code: degree_type.hesa_itt_code)).to eq(degree_type)
      end
    end

    describe ".find_institution" do
      let(:degree_institution) do
        DfE::ReferenceData::Degrees::INSTITUTIONS.all.find { |item| item[:hesa_itt_code].present? }
      end

      it "can find the institution by UUID" do
        expect(described_class.find_institution(uuid: degree_institution.id)).to eq(degree_institution)
      end

      it "can find the institution by name" do
        expect(described_class.find_institution(name: degree_institution.name)).to eq(degree_institution)
      end

      it "can find the institution by HESA code" do
        expect(described_class.find_institution(hesa_code: degree_institution.hesa_itt_code)).to eq(degree_institution)
      end
    end

    describe ".find_grade" do
      let(:degree_grade) do
        DfE::ReferenceData::Degrees::GRADES.all.find { |item| item[:hesa_code].present? }
      end

      it "can find the grade by UUID" do
        expect(described_class.find_grade(uuid: degree_grade.id)).to eq(degree_grade)
      end

      it "can find the grade by name" do
        expect(described_class.find_grade(name: degree_grade.name)).to eq(degree_grade)
      end

      it "can find the grade by HESA code" do
        expect(described_class.find_grade(hesa_code: degree_grade.hesa_code)).to eq(degree_grade)
      end
    end
  end
end

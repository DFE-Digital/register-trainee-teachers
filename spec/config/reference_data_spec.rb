# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reference data integrity" do
  types = [
    { file: "country.yml", v26: :country, v25: :country,
      gem_codes: -> { Hesa::CodeSets::Countries::MAPPING.keys } },
    { file: "course_age_range.yml", v26: :course_age_range, v25: :course_age_range,
      gem_codes: -> { DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.keys } },
    { file: "course_subject.yml", v26: :course_subject, v25: :course_subject_one,
      gem_codes: -> { Hesa::CodeSets::CourseSubjects::MAPPING.keys } },
    { file: "degree_subject.yml", v26: :degree_subject, v25: :subject,
      gem_codes: -> { DfEReference::DegreesQuery::SUBJECTS.all.map(&:hecos_code) },
      except: %w[100280 100610 100622 100623 100768 101445],
      entry_count: 1094, code_format: /^\d{6}$/ },
    { file: "degree_grade.yml", v26: :degree_grade, v25: :grade,
      gem_codes: -> { DfEReference::DegreesQuery::GRADES.all.map(&:hesa_code) } },
    { file: "degree_type.yml", v26: :degree_type, v25: :uk_degree,
      gem_codes: -> { DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code) },
      entry_count: 90, code_format: /^\d{3}$/ },
    { file: "disability.yml", v26: :disability, v25: :disability1,
      gem_codes: -> { Hesa::CodeSets::Disabilities::MAPPING.keys } },
    { file: "ethnicities.yml", v26: :ethnicity, v25: :ethnicity,
      gem_codes: -> { Hesa::CodeSets::Ethnicities::MAPPING.keys } },
    { file: "fund_code.yml", v26: :fund_code, v25: :fund_code,
      gem_codes: -> { Hesa::CodeSets::FundCodes::MAPPING.keys } },
    { file: "funding_method.yml", v26: :funding_method, v25: :funding_method,
      gem_codes: -> { Hesa::CodeSets::BursaryLevels::VALUES.keys } },
    { file: "institution.yml", v26: :institution, v25: :institution,
      gem_codes: -> { DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:hesa_itt_code) },
      entry_count: 602, code_format: /^\d{4}$/ },
    { file: "itt_aim.yml", v26: :itt_aim, v25: :itt_aim,
      gem_codes: -> { Hesa::CodeSets::IttAims::MAPPING.keys } },
    { file: "itt_qualification_aim.yml", v26: :itt_qualification_aim, v25: :itt_qualification_aim,
      gem_codes: -> { Hesa::CodeSets::IttQualificationAims::MAPPING.keys } },
    { file: "nationality.yml", v26: :nationality, v25: :nationality,
      gem_codes: -> { RecruitsApi::CodeSets::Nationalities::MAPPING.keys },
      accepted_names: {
        v25: -> { RecruitsApi::CodeSets::Nationalities::MAPPING.values },
        v26: -> { ReferenceData::NATIONALITIES.names_with_hesa_codes },
      } },
    { file: "sex.yml", v26: :sex, v25: :sex,
      gem_codes: -> { Hesa::CodeSets::Sexes::MAPPING.keys } },
    { file: "study_mode.yml", v26: :study_mode, v25: :study_mode,
      gem_codes: -> { Hesa::CodeSets::StudyModes::MAPPING.keys } },
    { file: "training_initiative.yml", v26: :training_initiative, v25: :training_initiative,
      gem_codes: -> { Hesa::CodeSets::TrainingInitiatives::MAPPING.keys } },
    { file: "training_route.yml", v26: :training_route, v25: :training_route,
      gem_codes: -> { Hesa::CodeSets::TrainingRoutes::MAPPING.keys },
      except: %w[21] },
  ].freeze

  def load_data(file)
    YAML.load_file(Rails.root.join("config/reference_data/#{file}"))["data"]
  end

  def normalize(codes)
    codes.map(&:to_s).reject(&:empty?).sort.uniq
  end

  def yaml_codes(file)
    normalize(load_data(file).flat_map { |e| Array(e["hesa_codes"]) })
  end

  def v2026_labels_by_code(v26_type)
    Hesa::ReferenceData::V20261.all[v26_type].each_with_object({}) do |(code, label), hash|
      (hash[code.to_s] ||= []) << label
    end
  end

  def divergences_from_v25(v25_published, labels_by_code, except:)
    v25_published.each_with_object([]) do |(code, v25_label), out|
      next if except.include?(code.to_s)

      actual = labels_by_code[code.to_s] || []
      out << "#{code}: expected #{v25_label.inspect} in #{actual.inspect}" unless actual.include?(v25_label)
    end
  end

  types.each do |type|
    describe type[:file] do
      let(:data) { load_data(type[:file]) }
      let(:v25_published) { Hesa::ReferenceData::V20250.all[type[:v25]] }
      let(:except_codes) { type[:except] || [] }

      if type[:entry_count]
        it "has expected entry count" do
          expect(data.count).to eq(type[:entry_count])
        end
      end

      if type[:code_format]
        it "has HESA codes in expected format" do
          codes = data.flat_map { |e| e["hesa_codes"] }.compact.reject(&:empty?)
          expect(codes).to all(match(type[:code_format]))
        end

        it "has no duplicate IDs" do
          duplicates = data.map { |e| e["id"] }.tally.select { |_, count| count > 1 }.keys
          expect(duplicates).to be_empty
        end
      end

      it "has no duplicate HESA codes" do
        codes = data.flat_map { |e| Array(e["hesa_codes"]) }.compact_blank
        duplicates = codes.tally.select { |_, count| count > 1 }.keys
        expect(duplicates).to be_empty
      end

      it "HESA codes match v2025" do
        expect(yaml_codes(type[:file])).to eq(normalize(type[:gem_codes].call))
      end

      it "labels match v2025 published" do
        divergences = divergences_from_v25(v25_published, v2026_labels_by_code(type[:v26]), except: except_codes)
        expect(divergences).to be_empty, "v2026 labels diverge from v2025:\n#{divergences.join("\n")}"
      end

      if type[:accepted_names]
        it "API accepted names match v2025" do
          v25 = type[:accepted_names][:v25].call.uniq.sort
          v26 = type[:accepted_names][:v26].call.sort
          expect(v26).to eq(v25), "only in v2026: #{(v26 - v25).inspect}\nonly in v2025: #{(v25 - v26).inspect}"
        end
      end
    end
  end
end

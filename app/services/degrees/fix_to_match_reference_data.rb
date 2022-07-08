# frozen_string_literal: true

module Degrees
  class FixToMatchReferenceData
    include ServicePattern

    def initialize(degree:)
      @degree = degree
    end

    def call
      params_to_update = existing_degree_values.merge(update_params)

      if params_to_update != existing_degree_values
        degree.update_columns(update_params)
      end

      degree
    end

  private

    attr_reader :degree

    def existing_degree_values
      @existing_degree_values ||= degree.uk? ? uk_degree_values : non_uk_degree_values
    end

    def uk_degree_values
      {
        institution: degree.institution,
        subject: degree.subject,
        grade: degree.grade,
        uk_degree: degree.uk_degree,
      }
    end

    def non_uk_degree_values
      {
        subject: degree.subject,
        grade: degree.grade,
      }
    end

    def update_params
      degree.uk? ? uk_update_params : non_uk_update_params
    end

    def uk_update_params
      {
        institution: correct_institution(:name),
        institution_uuid: correct_institution(:id),
        subject: correct_subject(:name),
        subject_uuid: correct_subject(:id),
        grade: correct_grade(:name),
        grade_uuid: correct_grade(:id),
        uk_degree: correct_type(:name),
        uk_degree_uuid: correct_type(:id),
      }.compact
    end

    def non_uk_update_params
      {
        subject: correct_subject(:name),
        grade: correct_grade(:name),
      }.compact
    end

    def correct_subject(param)
      ref_version = find_in_reference_data(:subjects, degree.subject)
      return ref_version[param] if ref_version
    end

    def correct_institution(param)
      ref_version = find_in_reference_data(:institutions, degree.institution)
      return ref_version[param] if ref_version
    end

    def correct_grade(param)
      ref_version = find_in_reference_data(:grades, degree.grade)
      return ref_version[param] if ref_version
    end

    def correct_type(param)
      ref_version = find_in_reference_data(:types, degree.uk_degree)
      return ref_version[param] if ref_version
    end

    def find_in_reference_data(collection_constant, value)
      return if value.nil?

      refdataset = DfE::ReferenceData::Degrees.const_get(collection_constant.to_s.upcase)
      by_key = refdataset.some(name: value).first
      return by_key if by_key.present?

      synonym_key = collection_constant == :institutions ? :match_synonyms : :synonyms

      refdataset.all.find do |item|
        item[synonym_key].include?(value) ||
          item.name.downcase == value.downcase
      end
    end
  end
end

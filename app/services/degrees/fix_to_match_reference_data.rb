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
        institution_uuid: degree.institution_uuid,
        subject: degree.subject,
        subject_uuid: degree.subject_uuid,
        grade: degree.grade,
        grade_uuid: degree.grade_uuid,
        uk_degree: degree.uk_degree,
        uk_degree_uuid: degree.uk_degree_uuid,
      }
    end

    def non_uk_degree_values
      {
        subject: degree.subject,
        subject_uuid: degree.subject_uuid,
        grade: degree.grade,
        grade_uuid: degree.grade_uuid,
      }
    end

    def update_params
      degree.uk? ? uk_update_params : non_uk_update_params
    end

    def uk_update_params
      {
        institution: correct_institution[:name],
        institution_uuid: correct_institution[:id],
        subject: correct_subject[:name],
        subject_uuid: correct_subject[:id],
        grade: correct_grade[:name],
        grade_uuid: correct_grade[:id],
        uk_degree: correct_type[:name],
        uk_degree_uuid: correct_type[:id],
      }.compact
    end

    def non_uk_update_params
      {
        subject: correct_subject[:name],
        subject_uuid: correct_subject[:id],
        grade: correct_grade[:name],
        grade_uuid: correct_grade[:id],
      }.compact
    end

    def correct_subject
      ref_version = find_in_reference_data(:single_subjects, degree.subject)
      ref_version || {}
    end

    def correct_institution
      ref_version = find_in_reference_data(:institutions, degree.institution)
      ref_version || {}
    end

    def correct_grade
      ref_version = find_in_reference_data(:grades, degree.grade)
      ref_version || {}
    end

    def correct_type
      ref_version = find_in_reference_data(:types_including_generics, degree.uk_degree)
      ref_version || {}
    end

    def find_in_reference_data(collection_constant, value)
      return if value.nil?

      refdataset = DfE::ReferenceData::Degrees.const_get(collection_constant.to_s.upcase)
      by_key = refdataset.some(name: value).first
      return by_key if by_key.present?

      refdataset.all.find do |item|
        match_values(item).include?(value.downcase.strip)
      end
    end

    def match_values(item)
      [item[:name], item[:match_synonyms], item[:abbreviation]].flatten.compact.map(&:downcase).map(&:strip)
    end
  end
end

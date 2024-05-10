# frozen_string_literal: true

require "csv"

module Trainees
  class CreateFromBulkCsv
    include ServicePattern

    attr_reader :provider, :csv_path

    def initialize(provider:, csv_path:)
      @provider = provider
      @csv_path = csv_path
    end

    def call
      CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
        trainee_attributes = trainee_attributes_service.new(hesa_mapped_params(row))
        result = Api::CreateTrainee.call(current_provider: provider, trainee_attributes: trainee_attributes, version: version)
        Rails.logger.info(result)
      end
    rescue StandardError => e
      Rails.logger.error("Failed to process CSV file: #{e.message}")
    end

  private

    def hesa_mapped_params(row)
      hesa_mapper_class.call(
        params: map_row_to_params(row),
      )
    end

    def map_row_to_params(row)
      {
        provider_trainee_id: row[:provider_trainee_id],
        first_names: row[:first_names],
        last_name: row[:last_name],
        previous_last_name: row[:previous_last_name],
        date_of_birth: row[:date_of_birth],
        sex: row[:sex],
        email: row[:email],
        training_route: row[:training_route],
        itt_start_date: row[:itt_start_date],
        itt_end_date: row[:itt_end_date],
        course_subject_one: row[:course_subject_one],
        study_mode: row[:study_mode],
        nationality: row[:nationality],
        ethnicity: row[:ethnicity],
        disability1: row[:disability1],
        itt_aim: row[:itt_aim],
        itt_qualification_aim: row[:itt_qualification_aim],
        course_year: row[:course_year],
        course_age_range: row[:course_age_range],
        fund_code: row[:fund_code],
        funding_method: row[:funding_method],
        hesa_id: row[:hesa_id],
        placements_attributes: [{
          urn: row[:placement_urn1],
          name: row[:placement_name1],
        }],
        degrees_attributes: [{
          grade: row[:degree_grade1],
          subject: row[:degree_subject1],
          institution: row[:degree_institution1],
          uk_degree: row[:degree_uk_degree1],
          graduation_year: row[:degree_graduation_year1],
        }],
      }
    end

    def trainee_attributes_service
      Api::Attributes.for(model: :trainee, version: version)
    end

    def hesa_mapper_class
      Object.const_get("Api::MapHesaAttributes::#{version.gsub('.', '').camelize}")
    end

    def version
      ApiDocs::ReferenceController::CURRENT_VERSION
    end
  end
end

# frozen_string_literal: true

module Hesa
  class UploadTrnFile
    include ServicePattern

    class TrnFileUploadError < StandardError; end

    def initialize(trainees:)
      @trainees = trainees
      @url = "#{Settings.hesa.trn_file_base_url}/#{Settings.hesa.current_collection_reference}"
    end

    def call
      return if trainees.empty?

      file = Mechanize::Form::FileUpload.new({ "name" => "file" }, "trn_file.csv")
      file.file_data = build_csv
      response = Hesa::Client.upload_trn_file(url:, file:)
      raise(TrnFileUploadError, response.body) if response.code != "200"

      file.file_data
    end

  private

    attr_reader :trainees, :url

    def build_csv
      CSV.generate do |csv|
        csv << %w[UKPRN HUSID TRN]
        trainees.each do |trainee|
          csv << [trainee.provider.ukprn, trainee.hesa_id, trainee.trn]
        end
      end
    end
  end
end

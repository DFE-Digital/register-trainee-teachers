# frozen_string_literal: true

module Hesa
  class Backfill
    include ServicePattern

    def initialize(
      trns: nil,
      read_write: false,
      collection_reference: Settings.hesa.current_collection_reference,
      from_date: Settings.hesa.current_collection_start_date
    )
      @trns = [trns].flatten.compact
      @read_write = read_write
      @collection_reference = collection_reference
      @from_date = from_date
    end

  private

    attr_reader :trns, :read_write, :collection_reference, :from_date

    def xml_response
      @xml_response ||= if read_write && File.exist?(xml_file_path)
                          File.read(xml_file_path)
                        else
                          response = Hesa::Client.get(url: url)
                          File.write(xml_file_path, response.force_encoding("UTF-8")) if read_write
                          response
                        end
    end

    def url
      "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{from_date}"
    end

    def xml_file_path
      "tmp/#{collection_reference}_#{from_date}.xml"
    end
  end
end

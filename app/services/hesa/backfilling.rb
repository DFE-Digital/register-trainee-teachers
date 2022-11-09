# frozen_string_literal: true

module Hesa
  class Backfilling
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

    def call
      return unless trainee_trns.any?

      Trainee.where(trn: trainee_trns).find_each do |trainee|
        Degree.without_auditing do
          ::Degrees::CreateFromHesa.call(
            trainee: trainee,
            hesa_degrees: trainees_with_degrees[trainee.trn],
          )
        end
      end
    end

  private

    attr_reader :trns, :read_write, :collection_reference, :from_date

    def trainees_with_degrees
      return @trainees_with_degrees if @trainees_with_degrees

      @trainees_with_degrees = {}

      Nokogiri::XML::Reader(xml_response).each do |node|
        next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        trn = Nokogiri::XML(node.outer_xml).at("./Student/F_TRN")&.children&.first&.text
        next unless trn && (trns.empty? || trns.include?(trn))

        degrees = Nokogiri::XML(node.outer_xml).at("./Student/PREVIOUSQUALIFICATIONS")
        next unless degrees

        degrees = Hash.from_xml(degrees.to_s)["PREVIOUSQUALIFICATIONS"]
        degrees = ::Hesa::Parsers::IttRecord.convert_all_null_values_to_nil(degrees)
        degrees = ::Hesa::Parsers::IttRecord.to_degrees_attributes(degrees)

        @trainees_with_degrees[trn] = degrees
      end

      @trainees_with_degrees
    end

    def trainee_trns
      @trainee_trns ||= trainees_with_degrees.keys
    end

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

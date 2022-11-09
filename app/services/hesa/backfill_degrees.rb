# frozen_string_literal: true

module Hesa
  class BackfillDegrees < Backfill
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
  end
end

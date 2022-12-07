# frozen_string_literal: true

module Hesa
  class BackfillDegrees < Backfill
    def call
      return unless trainee_hesa_ids.any?

      Trainee.where(hesa_id: trainee_hesa_ids).find_each do |trainee|
        Degree.without_auditing do
          ::Degrees::CreateFromHesa.call(
            trainee: trainee,
            hesa_degrees: trainees_with_degrees[trainee.hesa_id],
          )
        end
      end
      Rails.logger.debug("Finish upating Trainees")
    ensure
      tidy_up!
    end

  private

    def trainees_with_degrees
      return @trainees_with_degrees if @trainees_with_degrees

      @trainees_with_degrees = {}

      Rails.logger.debug("Reading XML")
      Nokogiri::XML::Reader(xml).each do |node|
        next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        hesa_id = Nokogiri::XML(node.outer_xml).at("./Student/F_HUSID")&.children&.first&.text
        next unless hesa_id && (hesa_ids.empty? || hesa_ids.include?(hesa_id))

        degrees = Nokogiri::XML(node.outer_xml).at("./Student/PREVIOUSQUALIFICATIONS")
        next unless degrees

        degrees = Hash.from_xml(degrees.to_s)["PREVIOUSQUALIFICATIONS"]
        degrees = ::Hesa::Parsers::IttRecord.convert_all_null_values_to_nil(degrees)
        degrees = ::Hesa::Parsers::IttRecord.to_degrees_attributes(degrees)

        @trainees_with_degrees[hesa_id] = degrees
      end
      Rails.logger.debug("Finish reading XML")
      Rails.logger.debug("")
      Rails.logger.debug("Upating Trainees")

      @trainees_with_degrees
    end

    def trainee_hesa_ids
      @trainee_hesa_ids ||= trainees_with_degrees.keys
    end
  end
end

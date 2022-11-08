# frozen_string_literal: true

module Hesa
  class Backfilling
    include ServicePattern

    def initialize(
      trns:,
      read_write: false,
      collection_reference: Settings.hesa.current_collection_reference,
      from_date: Settings.hesa.current_collection_start_date
    )
      @trns = [trns].flatten
      @read_write = read_write
      @update = update
      @collection_reference = collection_reference
      @from_date = from_date
    end

    def call
      Rails.logger.debug { "Total student nodes: #{total_nodes}" }

      Nokogiri::XML::Reader(xml_response).each do |node|
        next unless node.name == "Student" && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT

        student_node = Nokogiri::XML(node.outer_xml).at("./Student")
        hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)

        # We're either backfilling everything, or specific Trainees
        if trns.empty? || trns.include?(hesa_trainee[:trn])
          Degree.without_auditing do
            trainee = Trainee.find_by(hesa_id: hesa_trainee[:hesa_id])
            if trainee
              Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_trainee[:degrees])
            end
          end
        end
        bar.increment
      end
    end

  private

    attr_reader :trns, :read_write, :update, :collection_reference, :from_date

    def bar
      @bar ||= ProgressBar.create(total: total_nodes)
    end

    def total_nodes
      @total_nodes ||= xml_doc.root.children.size
    end

    def xml_doc
      @xml_doc ||= Nokogiri::XML(xml_response)
    end

    def xml_response
      @xml_respnse ||= if read_write && File.exist?(xml_file_path)
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

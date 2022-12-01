# frozen_string_literal: true

module Hesa
  #
  # Can be used as a base class for HESA backfilling `write_xml` is by default set to `false`.
  #
  # Set this to true when running locally to save you from downloading the large HESA xml file
  # multiple times
  #
  # If the service needs access to a HESA xml file no available from them upload a file via
  # `/system-admin/uploads` and pass the `upload_id` to the service
  #
  class Backfill
    include ServicePattern

    def initialize(
      hesa_ids: nil,
      upload_id: nil,
      write_xml: false,
      path: "tmp",
      collection_reference: Settings.hesa.current_collection_reference,
      from_date: Settings.hesa.current_collection_start_date
    )
      @hesa_ids = [hesa_ids].flatten.compact
      @write_xml = write_xml
      @path = path
      @collection_reference = collection_reference
      @from_date = from_date
      @upload = Upload.find_by(id: upload_id)
    end

  private

    attr_reader :hesa_ids, :upload, :path, :collection_reference, :from_date

    def xml
      @xml ||= if uploaded_xml
                 uploaded_xml.read.to_s
               elsif local_xml
                 local_xml.read
               else
                 Hesa::Client.get(url:)
               end
    end

    def url
      "#{Settings.hesa.collection_base_url}/#{collection_reference}/#{from_date}"
    end

    def tidy_up!
      uploaded_xml&.close
      uploaded_xml&.unlink
      local_xml&.close
    end

    ##############
    # Via Upload #
    ##############

    def uploaded_xml
      return @uploaded_xml if defined?(@uploaded_xml)

      build_uploaded_xml!
      @uploaded_xml
    end

    def build_uploaded_xml!
      return if upload.nil?

      @uploaded_xml = Tempfile.new(upload&.name, encoding: "UTF-8")
      @uploaded_xml.binmode
      upload.file.download do |chunk|
        @uploaded_xml.write(chunk)
      end
      @uploaded_xml.rewind
    end

    ##################
    # Via Local File #
    ##################

    def write_xml?
      @write_xml.present?
    end

    def local_xml
      return @local_xml if defined?(@local_xml)

      build_local_xml!
      @local_xml
    end

    def build_local_xml!
      return unless write_xml?

      FileUtils.mkdir_p(path)
      File.write(local_xml_path, Hesa::Client.get(url:).force_encoding("UTF-8")) unless File.exist?(local_xml_path)
      @local_xml = File.new(local_xml_path)
    end

    def local_xml_path
      @local_xml_path ||= Rails.root.join("#{path}/#{collection_reference}_#{from_date}.xml")
    end
  end
end

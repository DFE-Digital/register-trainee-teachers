# frozen_string_literal: true

module Funding
  module Parsers
    class Base
      class << self
        def id_column
          raise(NotImplementedError("implement in subclass"))
        end

        def expected_headers
          raise(NotImplementedError("implement in subclass"))
        end

        def to_attributes(funding_upload = nil, file_path = nil)
          csv_data = file_path ? File.read(file_path) : funding_upload&.csv_data
          raise ArgumentError, "Either funding_upload or file_path must be provided" unless csv_data

          csv = CSV.parse(csv_data, headers: true)

          validate_headers(csv: csv)

          csv.each_with_object({}) do |row, to_return|
            to_return[row[id_column]] = Array(to_return[row[id_column]]) << row.to_h
          end
        end

        def validate_headers(csv:)
          csv_headers = csv.first.to_h.keys
          unrecognised_headers = csv_headers.select { |header| expected_headers.exclude?(header) }
          if unrecognised_headers.any?
            raise(NameError, "Column headings: #{unrecognised_headers.join(', ')} not recognised")
          end
        end
      end
    end
  end
end

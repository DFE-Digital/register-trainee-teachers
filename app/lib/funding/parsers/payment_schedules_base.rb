# frozen_string_literal: true

module Funding
  module Parsers
    class PaymentSchedulesBase
      class << self
        def id_column
          raise(NotImplementedError("implement in subclass"))
        end

        def to_attributes(file_path:)
          csv = CSV.open(file_path, headers: true)

          validate_headers(csv: csv)

          csv.each_with_object({}) do |row, to_return|
            to_return[row[id_column]] = Array(to_return[row[id_column]]) << row.to_h
          end
        end

        def validate_headers(csv:)
          csv_headers = csv.first.to_h.keys
          csv.rewind
          unrecognised_headers = csv_headers.select { |header| expected_headers.exclude?(header) }
          if unrecognised_headers.any?
            raise(NameError, "Column headings: #{unrecognised_headers.join(', ')} not recognised")
          end
        end
      end
    end
  end
end

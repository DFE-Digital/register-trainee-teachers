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

          csv.each_with_object({}) do |row, to_return|
            to_return[row[id_column]] = Array(to_return[row[id_column]]) << row.to_h
          end
        end
      end
    end
  end
end

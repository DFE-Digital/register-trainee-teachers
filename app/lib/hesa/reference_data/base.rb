# frozen_string_literal: true

# rubocop:disable  Rails/RedundantActiveRecordAllMethod
module Hesa
  module ReferenceData
    class Base
      def self.all
        raise(NotImplementedError("::all must be implemented"))
      end

      def self.find(attribute)
        new(
          all.fetch(attribute.to_sym)
        )
      end

      attr_reader :values

      def initialize(values)
        @values = values
      end

      def as_csv
        CSV.generate do |f|
          f << %w[Code Label]

          values.each do |code, label|
            f << [code, label]
          end
        end
      end
    end
  end
end
# rubocop:enable  Rails/RedundantActiveRecordAllMethod

# frozen_string_literal: true

# takes the headers defined in a Bulk export and returns us a cleaner way
# to access the CSV row attributes e.g.:
#
# row = Row.new({ "TRN" => "1234567" })
# #<Row:0x007fb3a1755178 @trn="1234567">
# row.trn
# #=> "1234567"
#
module BulkUpdate
  class RowBase
    def initialize(csv_row)
      @csv_row = csv_row
      set_methods!
    end

    def empty?
      instance_variables.all? do |variable|
        value = instance_variable_get(variable)
        value.blank? || value.to_s.strip.empty?
      end
    end

  private

    attr_reader :csv_row

    def set_methods!
      headers.each do |header|
        method_name = header.downcase.gsub(" ", "_")
        method_value = csv_row[header.downcase]

        instance_variable_set("@#{method_name}", method_value)
        self.class.send(:attr_reader, method_name)
      end
    end

    def headers
      raise(NotImplementedError)
    end
  end
end

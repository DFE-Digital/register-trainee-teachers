# frozen_string_literal: true

module ErrorMessageHelper
  def format_reference_data_list(values)
    values.map { |v| "'#{v}'" }.join(", ")
  end
end

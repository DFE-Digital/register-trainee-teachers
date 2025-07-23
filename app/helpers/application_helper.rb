# frozen_string_literal: true

module ApplicationHelper
  def to_options(array, first_value: nil)
    result = array.map do |name|
      SelectOption.new(value: name, text: name.upcase_first)
    end
    result.unshift(SelectOption.new(value: first_value, text: first_value&.upcase_first))
    result
  end

  def to_enhanced_options(data, &to_data_attrs)
    options = data.map { |name, attrs| to_data_attrs.call(name, attrs) }

    empty_result = [nil, nil, nil]
    options.unshift(empty_result).compact
  end

  def register_form_with(*args, &)
    options = args.extract_options!
    options[:model] ||= false

    defaults = {
      html: {
        novalidate: true,
        autocomplete: :off,
        "data-js-disable-browser-autofill": :on,
        spellcheck: false,
      },
    }

    form_with(*args, **defaults.deep_merge(options), &)
  end
end

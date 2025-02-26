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

  def header_items(current_user)
    return unless current_user

    items = [
      { name: t("header.items.sign_out"), url: sign_out_path }
    ]

    if policy(:organisation_settings).show?
      items.unshift({ name: t("header.items.organisation_settings"), url: organisation_settings_path })
    end

    if current_user.system_admin?
      items.unshift({ name: t("header.items.system_admin"), url: users_path })
    end

    items
  end
end

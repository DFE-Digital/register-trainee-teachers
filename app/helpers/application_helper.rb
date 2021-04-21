# frozen_string_literal: true

module ApplicationHelper
  def to_options(array, first_value: nil)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: first_value))
    result
  end

  def register_form_with(*args, &block)
    options = args.extract_options!
    defaults = { html: { novalidate: true, autocomplete: :off, spellcheck: false } }
    form_with(*args << defaults.deep_merge(options), &block)
  end

  def header_items(current_user)
    return unless current_user

    items = [{ name: t("header.items.sign_out"), url: sign_out_path }]
    items.unshift({ name: t("header.items.system_admin"), url: providers_path }) if current_user.system_admin?
    items
  end

  def multiple_routes_enabled?
    TRAINING_ROUTE_FEATURE_FLAGS.any? { |flag| FeatureService.enabled?("routes.#{flag}") }
  end
end

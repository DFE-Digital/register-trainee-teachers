# frozen_string_literal: true

module SummaryHelper
  def date_for_summary_view(date)
    date&.strftime("%-d %B %Y")
  end

  def age_range_for_summary_view(age_range)
    age_range.join(" to ")
  end

  def mappable_field(field_value, field_label, section_url, has_errors)
    MappableFieldRow.new(
      field_value: field_value,
      field_label: field_label,
      text: t("components.confirmation.missing"),
      action_url: section_url,
      has_errors: has_errors,
    ).to_h
  end
end

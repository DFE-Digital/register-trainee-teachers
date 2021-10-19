# frozen_string_literal: true

module MappableFieldHelper
  def non_editable
    return false if system_admin

    trainee.recommended_for_award? || trainee.awarded? || trainee.withdrawn?
  end

  def mappable_field(field_value, field_label, action_url)
    MappableFieldRow.new(
      field_value: field_value,
      field_label: field_label,
      text: t("components.confirmation.missing"),
      action_url: action_url,
      has_errors: has_errors,
      apply_draft: trainee.apply_application?,
      non_editable: non_editable,
    ).to_h
  end

  def mappable_degree_field_row(degree, field_name, field_label, field_value)
    MappableFieldRow.new(
      invalid_data: trainee.apply_application&.degrees_invalid_data,
      record_id: degree.to_param,
      field_name: field_name,
      field_value: field_value || degree.public_send(field_name),
      field_label: field_label,
      text: t("components.confirmation.missing"),
      action_url: edit_trainee_degree_path(trainee, degree),
      has_errors: has_errors,
      apply_draft: trainee.apply_application?,
      non_editable: non_editable,
    ).to_h
  end
end

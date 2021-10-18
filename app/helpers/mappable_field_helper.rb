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
      non_editable: non_editable
    ).to_h
  end
end 
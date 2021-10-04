# frozen_string_literal: true

module MappingsHelper
  def same_hesa_code?(source_hesa, incoming_hesa)
    return false if source_hesa.blank? || incoming_hesa.blank?

    sanitised_hesa(source_hesa) == sanitised_hesa(incoming_hesa)
  end

  def same_string?(source_string, incoming_string)
    sanitised_word(source_string) == sanitised_word(incoming_string)
  end

  def almost_identical?(source_string, incoming_string)
    sanitised_word(incoming_string).start_with?(sanitised_word(source_string))
  end

  def sanitised_word(word)
    return if word.blank?

    word.downcase.gsub(/[^\w]/, "")
  end

  def sanitised_hesa(code)
    return if code.blank?

    # The hesa code can sometimes be padded with some leading zeros
    # So we need to sensibly convert the strings to their integer values for an equal comparison
    BigDecimal(code).to_i
  end
end

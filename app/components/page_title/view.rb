# frozen_string_literal: true

class PageTitle::View < ApplicationComponent
  def initialize(i18n_key: nil, text: nil, has_errors: false)
    @text = text
    @i18n_key = i18n_key
    @has_errors = has_errors
  end

  def build_page_title
    [build_error + build_title, I18n.t("service_name"), "GOV.UK"].compact_blank.join(" - ")
  end

private

  attr_reader :text, :i18n_key, :has_errors

  def build_error
    has_errors ? "Error: " : ""
  end

  def build_title
    return text if text.present?
    return "" if i18n_key.blank?

    I18n.t("components.page_titles.#{i18n_key}")
  end
end

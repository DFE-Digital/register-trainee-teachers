class PageTitle::View < GovukComponent::Base
  attr_accessor :title, :errors

  include ActiveModel

  def initialize(title: "", errors: false)
    @title = title
    @errors = errors.present?
  end

  def build_page_title
    [build_error + build_title + build_service_name, "GOV.UK"].join(" - ")
  end

private

  def build_error
    errors ? "Error: " : ""
  end

  def build_title
    title == "" ? "" : I18n.t("components.page_titles." + title)
  end

  def build_service_name
    title == "" ? I18n.t("service_name") : " - " + I18n.t("service_name")
  end
end

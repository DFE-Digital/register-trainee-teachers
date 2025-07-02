# frozen_string_literal: true

class ServiceUpdate
  SERVICE_UPDATES_YAML_FILE = Rails.root.join("db/service_updates.yml")

  include ActiveModel::Model

  attr_accessor :date, :title, :content, :summary

  def id
    title.parameterize
  end

  def self.all
    updates = YAML.load_file(SERVICE_UPDATES_YAML_FILE).map do |params|
      new(params)
    end

    updates.sort_by { |update| Date.parse(update.date) }.reverse
  end

  def self.find_by_id(id)
    all.find { |update| update.id == id }
  end

  def summary_text
    return summary if summary.present?

    content_lines = content.split("\n").compact_blank
    first_paragraph = content_lines.first&.strip

    if first_paragraph && first_paragraph.length > 200
      "#{first_paragraph[0, 200]}..."
    else
      first_paragraph || ""
    end
  end

  def summary_html
    custom_render = Redcarpet::Render::HTML.new(link_attributes: { class: "govuk-link" })
    Redcarpet::Markdown.new(custom_render).render(summary_text).html_safe
  end

  def self.recent_updates
    recent_updates = all.select { |service_update| service_update.date > 1.month.ago }

    recent_updates[0, 2]
  end
end

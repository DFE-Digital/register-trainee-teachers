# frozen_string_literal: true

class ServiceUpdate
  SERVICE_UPDATES_YAML_FILE = Rails.root.join("db/service_updates.yml")

  include ActiveModel::Model

  attr_accessor :date, :title, :content, :slug, :summary

  def id
    title.parameterize
  end

  def self.all
    YAML.load_file(SERVICE_UPDATES_YAML_FILE).map do |params|
      new(params)
    end
  end

  def self.recent_updates
    recent_updates = all.select { |service_update| service_update.date > 1.month.ago }

    recent_updates[0, 2]
  end

  def self.find(id)
    # TODO: Raise ActiveRecord::NotFound if id not found?
    all.find { |service_update| service_update.id == id }
  end
end

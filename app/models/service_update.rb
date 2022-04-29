# frozen_string_literal: true

class ServiceUpdate
  SERVICE_UPDATES_YAML_FILE = Rails.root.join("db/service_updates.yml")

  include ActiveModel::Model

  attr_accessor :date, :title, :content

  def id
    title.parameterize
  end

  def self.all
    YAML.load_file(SERVICE_UPDATES_YAML_FILE).map do |params|
      new(params)
    end
  end

  def self.recent_updates
    all.select { |service_update| service_update.date > 1.month.ago }
  end
end

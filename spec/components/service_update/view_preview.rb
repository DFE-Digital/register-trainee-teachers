# frozen_string_literal: true

class ServiceUpdate::ViewPreview < ViewComponent::Preview
  def default
    render(ServiceUpdate::View.new(service_update: ServiceUpdate.new(title: "Hello world", content: "Testing 123", date: Time.zone.today)))
  end
end

# frozen_string_literal: true

module ApiMonitorable
  extend ActiveSupport::Concern

  included do
    around_action :monitor_api_request
  end

private

  def monitor_api_request
    yield
  rescue StandardError => e
    track_unsuccessful_requests(e)
    raise(e)
  ensure
    track_response_size
  end

  def track_unsuccessful_requests(error)
    labels = tracking_labels.merge(error_code: error.class.name, error_message: error.message[0, 100])
    Yabeda.register_api.unsuccessful_requests_total.increment(labels)
  end

  def track_response_size
    response_size = response.body.bytesize
    Yabeda.register_api.response_size.measure(tracking_labels, response_size)
  end

  def tracking_labels
    @tracking_labels ||= {
      method: request.method,
      controller: controller_name,
      action: action_name,
    }
  end
end

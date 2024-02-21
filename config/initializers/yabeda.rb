# frozen_string_literal: true

Yabeda.configure do
  group :register_api do
    counter   :requests_total, comment: "Total number of Request API requests"
    histogram :request_duration,
              buckets: [0.1, 0.5, 1, 5, 10],
              unit: :seconds,
              comment: "Request API request duration"
  end
end

# frozen_string_literal: true

Yabeda.configure do
  group :register_api do
    counter   :requests_total,
              comment: "Total number of Register API requests",
              tags: %i[method controller action]

    histogram :request_duration,
              buckets: [0.1, 0.5, 1, 5, 10],
              unit: :seconds,
              comment: "Request API request duration",
              tags: %i[method controller action]

    counter :unsuccessful_requests_total,
            comment: "Total number of unsuccessful Register API requests",
            tags: %i[method controller action error_code error_message]

    histogram :response_size,
              buckets: [100, 1_000, 10_000, 100_000, 1_000_000],
              comment: "Response sizes",
              unit: :byte,
              per: :request,
              tags: %i[method controller action]
  end
end

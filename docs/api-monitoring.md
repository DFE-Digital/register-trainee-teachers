# API Monitoring Guide for Register

* We use [yabeda](https://github.com/yabeda-rb/yabeda) with the [yabeda-rails](https://github.com/yabeda-rb/yabeda-rails) gem to define and collect custom metrics from our Rails application. 
* Yabeda is a framework that provides a simple DSL to declare and manage monitoring metrics. The `yabeda-rails` gem automatically configures Yabeda with Rails specific hooks. 
* We then use [yabeda-prometheus](https://github.com/yabeda-rb/yabeda-prometheus) to expose our collected metrics to Prometheus using a `/metrics` endpoint. 
* Prometheus then ingests them and allows us to build dashboards around them using [Grafana](https://grafana.com). At the time of writing, we do this in our routes file like so: 

```ruby
mount Yabeda::Prometheus::Exporter => "/metrics"
```

### Configuration

The configuration of Yabeda within our application is defined in the initializer `app/initializers/yabeda.rb`. Here we define all of the metrics that we want to track throughout our app. Things like the total number of requests, the request duration etc. 

```ruby
Yabeda.configure do
  group :register_api do
    counter   :requests_total,
              comment: "Total number of Register API requests",
              tags: %i[method controller action]
  end
end
```

We then add to these metrics from anywhere in our app that we choose. At the time of writing we're doing this in our API's base controller with an around_action: 

```ruby
...
  included do
    around_action :monitor_api_request
  end

  private

  def monitor_api_request
    start = Time.zone.now
    track_total_requests
    begin
      yield
    rescue => ex
      track_unsuccessful_requests(ex)
      raise ex
    ensure
      track_request_duration(start)
      track_response_size
    end
  end
...
```

### Grafana Dashboards

Grafana is configured to visualize the metrics collected by Prometheus. It supports additional data sources, providing a comprehensive view of our application’s operational metrics.

### Accessing Grafana Instances

* Test Environment: [https://grafana.test.teacherservices.cloud/](https://grafana.test.teacherservices.cloud/)
* Production Environment: [https://grafana.teacherservices.cloud/](https://grafana.teacherservices.cloud/)

### Adding New Dashboards

To add new dashboards or modify existing ones in Grafana, follow the Monitoring documentation in the [teacher-services-cloud](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/developer-onboarding.md#monitoring) repository. Or reach out to someone on the infrastructure team to help with this.

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

We then add to these metrics from anywhere in our app that we choose. At the time of writing we’re doing this in our API’s base controller with an around_action:

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

### Grafana Overview
Once we know that Prometheus is ingesting the data correctly, you’ll likely want to setup a dashboard in Grafana to visualise the data. To do this, follow these steps:

1. Log in to Grafana and choose "Dashboards" from the menu on the right:

<img width="1323" alt="Screenshot 2024-10-21 at 11 38 58" src="https://github.com/user-attachments/assets/681da559-e96b-4cff-93d9-b2fddb931e3e">

2. Either choose from the list of dashboards, or choose "New" to create a new dashboard. Here’s the Register API dashboard for example:

<img width="1322" alt="Screenshot 2024-10-21 at 11 39 26" src="https://github.com/user-attachments/assets/178deb28-b125-4268-b8fc-1c1b8fb647e4">

3. Choose "Add" from the menu at the top of the page, and then choose "Visualisation"

<img width="1321" alt="Screenshot 2024-10-21 at 11 39 40" src="https://github.com/user-attachments/assets/0bf49e07-2fd5-49e1-8e2b-371528aecc6a">

4. You should now see a blank visualisation with no data. To add data, click on the "Metric" dropdown to choose which metric you want to see:

<img width="1322" alt="Screenshot 2024-10-21 at 11 40 14" src="https://github.com/user-attachments/assets/a65c88b3-b90f-4147-b06f-42b0debcaaa3">

5. From the dropdown, click on the option at the top for "Metrics Explorer". Not all available metrics will appear in the initial list, so it’s best to do the search here.

<img width="1323" alt="Screenshot 2024-10-21 at 11 40 24" src="https://github.com/user-attachments/assets/2e516378-53d9-41c3-9e3a-665b9b87a33d">

6. Some metrics are tracked by default, without anything custom needed from the developer. These metrics are prefixed with "rails":

<img width="1325" alt="Screenshot 2024-10-21 at 11 40 34" src="https://github.com/user-attachments/assets/55e2544c-2c9a-4dcc-8f37-9a5c339c3744">

7. From there, you should see some data displayed in the viewer, we can now refine our query from this point to show us what we want.

<img width="1374" alt="Screenshot 2024-10-21 at 11 52 40" src="https://github.com/user-attachments/assets/f30ca607-681d-4ff3-b1f5-86137396f17e">

8. Choose the code option for the metric to edit the query:

<img width="1372" alt="Screenshot 2024-10-21 at 11 52 56" src="https://github.com/user-attachments/assets/a264eef3-4cd9-439f-9cf9-fb302d8abbac">

9. The metric can now be queried using the following syntax:

<img width="1372" alt="Screenshot 2024-10-21 at 12 05 05" src="https://github.com/user-attachments/assets/f28c2e12-6570-443e-83b7-418540828c40">

This is filtering by the "controller" property and providing a regular expression to show only those controllers with the "api" prefix.

10. You can also sum the results to show the data across all instances as a single value:

<img width="1375" alt="Screenshot 2024-10-21 at 12 05 18" src="https://github.com/user-attachments/assets/20d74852-786c-42ad-9bb9-0f6828dae39d">

There are many different ways to query display data in Grafana, and this is just one example. The menu on the right can show you different types of charts and graphs available.


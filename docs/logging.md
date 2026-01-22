# Logging Documentation

## Rails Semantic Logger
We use [`rails_semantic_logger`](https://github.com/reidmorrison/rails_semantic_logger) instead of the default Rails logger because it provides enhanced logging capabilities. It solves several problems such as:
- **Structured Logging**: Allows logs to be output in a structured format like JSON, making it easier to parse and analyze.
- **Multiple Output Formats**: Supports different log output formats and destinations, providing flexibility in how logs are handled.
- **Performance**: Offers better performance with asynchronous logging, reducing the impact on application throughput.
- **Log Filtering**: Provides advanced filtering options to control which logs are recorded, helping to reduce noise and focus on important information.

## Custom Log Formatter
The `CustomLogFormatter` class in [`app/lib/custom_log_formatter.rb`](../app/lib/custom_log_formatter.rb) customizes the log format. It extends `SemanticLogger::Formatters::Json` to provide a JSON formatted log output. This custom formatter adds job data, formats exceptions, and modifies the log message context.

## Configuration in Production
In [`config/environments/production.rb`](../config/environments/production.rb), the logging is set up using the `CustomLogFormatter`. The configuration includes:
- Disabling the file appender.
- Setting the log format to use `CustomLogFormatter`.
- Adding an appender for `stdout` with the custom formatter.

This configuration is shared across all environments except for the test and development environments.

## Viewing Logs
Logs are viewed in Logit.io. Please replace the placeholders with the actual links:
- [Production Logs](https://kibana-uk1.logit.io/s/e9b9162d-0b5e-4362-bed0-8e577f88d06e/app/data-explorer/discover#?_a=(discover:(columns:!(_source),isDirty:!f,sort:!()),metadata:(indexPattern:'filebeat-*',view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-15m,to:now))&_q=(filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'filebeat-*',key:kubernetes.container.name,negate:!f,params:!(register-production,register-production-worker),type:phrases,value:'register-production,%20register-production-worker'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(kubernetes.container.name:register-production)),(match_phrase:(kubernetes.container.name:register-production-worker))))))),query:(language:kuery,query:'')))
- [QA Logs](https://kibana-uk1.logit.io/s/b2876053-0173-44fc-983d-99567292ba31/app/data-explorer/discover#?_a=(discover:(columns:!(kubernetes.container.name,app.message,app.payload.controller,url.path),isDirty:!t,sort:!()),metadata:(indexPattern:'filebeat-*',view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-10m,to:now))&_q=(filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'filebeat-*',key:app.name,negate:!t,params:(query:HeartbeatController),type:phrase),query:(match_phrase:(app.name:HeartbeatController))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'filebeat-*',key:kubernetes.container.name,negate:!f,params:!(register-qa,register-qa-worker),type:phrases,value:'register-qa,%20register-qa-worker'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(kubernetes.container.name:register-qa)),(match_phrase:(kubernetes.container.name:register-qa-worker))))))),query:(language:kuery,query:'')))

**Note:** the two different GUIDs used for Prod (production, productiondata, sandbox, staging) and Test (QA, review apps)

## Filebeat
[Filebeat](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/logit-io.md#logstash-inputs) is a lightweight shipper for forwarding and centralizing log data. It is used as an intermediary between our application and Logit.io, ensuring that logs are efficiently shipped to the logging service.

## References
- [Teacher Services Logit.io Dashboard](https://dashboard.logit.io/a/7ef698e1-d0ae-46c6-8d1e-a1088f5e034e)
- [Rails Semantic Logger Documentation](https://logger.rocketjob.io/index.html)
- [DevOps Guidance on Logit.io](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/logit-io.md)

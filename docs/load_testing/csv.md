# CSV load testing

We perform load testing on CSV bulk uploads with the use of [rake tasks](../../lib/tasks/load_test.rake)

1. Scale up staging env to match production env
2. `kubectl` in a staging pod `make staging ssh`
3. Execute `bin/rails load_test:csv_trainee_upload UPLOADS=10`
4. Monitor worker pods in Grafana dashboards
5. Monitor db metrics in Azure Metrics
6. Document the results on Confluence

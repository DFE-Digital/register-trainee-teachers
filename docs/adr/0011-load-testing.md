# 11. Load testing

Date: 2025-09-08

## Status

Accepted

## Context

In prepation of launching the Register API, we had to ensure it can perform at scale.

We also had to prepare for the launch of the CSV bulk creation of trainees. An intensive task which is executed
through multiple background jobs.

For the above reasons we evaluated a number of load testing tools and techniques to ensure uninterrupted uptime and performance for the service.

## Options

### API

#### 1. [wrk](https://github.com/wg/wrk)

##### Pros

* Easy to use through the command line
* Supports cli scripts in lua
* Sufficient for local testing on localhost

##### Cons

* Lacks documentation on how to perform load testing on a live environment
* No web based interface
* Familiarity with lua

#### 2. [Grafana k6](https://k6.io/)

##### Pros

* Support for cli scripts in js
* Support for GitHub actions CI and Cloud based tests
* Web based test builder (Grafana Cloud)
* Grafana dashboards to visualise the results (Grafana Cloud)
* Tests can be scheduled through the dashboard (Grafana Cloud)

##### Cons

* js based scripts might end up complex

#### 3. [Azure App Testing](https://azure.microsoft.com/en-us/products/app-testing/)

##### Pros

* Web based load testing through the Azure portal
* Support for GitHub actions CI
* A web based test can be converted to a JMeter test through the portal
* We host the app in Azure, might be easier having all the tools in one place

##### Cons

* Familiarity with JMeter XML

### CSV

#### 1. Manual uploads

##### Pros

* No extra setup required

##### Cons

* Can't simulate multiple uploads at scale

#### 2. Programmatic uploads

##### Pros

* Simulate multiple uploads at scale
* More efficient and easier to execute

##### Cons

* Rake task has to be implemented

## Decision

* `k6` for load testing the API
* rake task for load testing the CSV bulk trainee creation

## Consequences

We can evaluate the performance of the API and CSV by simulating user load on demand. Based on the metrics we can react and scale accordingly.

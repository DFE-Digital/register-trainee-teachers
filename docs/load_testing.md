# Load Testing

Load testing with k6 can be performed either locally or on the [Grafana Cloud k6](https://grafana.com/products/cloud/k6/)

## Setup

The URI defaults to Staging environment

### Linux
#### Debian/Ubuntu

```
bash
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

#### Fedora/CentOS

Using dnf (or yum on older versions):

```
bash
sudo dnf install https://dl.k6.io/rpm/repo.rpm
sudo dnf install k6
```

#### MacOS

Using Homebrew:

```
brew install k6
```

## How to use

`cd k6_load_testing`


### Local

1. `cp .example.secrets.json .secrets.json`
2. Edit `.secrets.json`, as a minimum it requires the `apiKey` to be set to the `Provider's` authentication token.

### Cloud

1. Set the `AUTH_TOKEN` env var at the Grafana Cloud dashboard to the `Provider's` authentication token.

```
k6 cloud login --token K6_CLOUD_API_TOKEN
```

### Options

#### Test a specific endpoint

```
k6 run ./endpoints/get-trainees.ts
```

#### Test all the endpoints

```
k6 run k6-script.ts
```

#### Specify VUs and duration

```
k6 run --vus 10 --duration 10s k6-script.js
```

#### Cloud execution

```
k6 cloud login --token K6_CLOUD_API_TOKEN
k6 cloud run k6-script.js
```

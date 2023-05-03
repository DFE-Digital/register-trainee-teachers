# Azure Kubernetes Service / AKS cheatsheet

Requirements

Azure CIP account and access to the s189 subscription
- https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#onboarding-users
- request s189 access from the devops team

azure-cli installed locally
- see https://technical-guidance.education.gov.uk/infrastructure/dev-tools/#azure-cli

kubectl installed locally
- see https://github.com/DFE-Digital/teacher-services-cloud#kubectl

All examples below show qa usage and you should adapt accordingly.

### Cluster and app info

There are several AKS clusters, but only 2 are relevant for register services.

s189t01-tsc-test-aks
- in s189-teacher-services-cloud-test subscription
- in s189t01-tsc-ts-rg resource group
- contains bat-qa and bat-staging namespaces
- will hold register review apps, register-qa, register-staging
- PIM self approval required

s189p01-tsc-production-aks
- in s189-teacher-services-cloud-production subscription
- in s189p01-tsc-pd-rg resource group
- contains bat-production namespace
- will hold register-production and register-productiondata
- PIM approval required

## Authentication

### Raising a PIM request

You need to activate the role in the desired cluster below:
https://portal.azure.com/?Microsoft_Azure_PIMCommon=true#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/azurerbac

Example: Activate `s189-teacher-services-cloud-test`. It will be approved automatically after a few seconds

### Azure setup

```
$ az login
```

Select account for az:

```
$ az account set -s s189-teacher-services-cloud-test
```

Get access credentials for a managed Kubernetes cluster (passing the
resource group and the name):

```
$ az aks get-credentials -g s189t01-tsc-ts-rg -n s189t01-tsc-test-aks
```

When you have multiple cluster credentials loaded, you can switch between clusters

Display current context (current cluster will have an asterisk next to it)

```
$ kubectl config get-contexts
```

Switch to production cluster
```
$ kubectl config use-context s189p01-tsc-production-aks
```

## Show namespaces

```
$ kubectl get namespaces
```

## Show deployments

```
$ kubectl -n bat-qa get deployments
```

## Show pods

```
$ kubectl -n bat-qa get pods
```

## Get logs from a pod

Without tail:

```
$ kubectl -n bat-qa logs register-qa-some-number
```

Tail:

```
$ kubectl -n bat-qa logs register-qa-some-number -f
```

Logs from the ingress:

```
$ kubectl logs deployment/ingress-nginx-controller -f
```

Alternatively you can install kubetail and run:

```
$ kubetail -n bat-qa register-qa-*
```

## Open a shell

```
$ kubectl -n bat-qa get deployments
$ kubectl -n bat-qa exec -ti deployment/register-pr-1234 -- sh
```

Alternatively you can enter directly on a pod:

```
$ kubectl -n bat-qa exec -ti register-qa-some-number -- sh
```

## Show CPU / Memory Usage

All pods in a namespace:
```
kubectl -n bat-qa top pod
```

All pods:
```
kubectl top pod -A
```

## More info on a pod

```
$ kubectl -n bat-qa describe pods register-somenumber-of-the-pod
```

## Scaling

The app:
```
$ kubectl -n bat-qa scale deployment/register-loadtest --replicas 2
```

### Enter on console

```
kubectl -n bat-qa exec -ti register-loadtest-some-pod-number -- bundle exec rails c
```


### Running tasks

```
kubectl -n bat-qa exec -ti register-loadtest-some-pod-number -- bundle exec rake -T
```

### Access the DB

```
make install-konduit
bin/konduit.sh app-name -- psql
```

Example of loading test:

```
bin/konduit.sh register-loadtest -- psql
```

## More info

For more info see
[Kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

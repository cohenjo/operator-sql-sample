# Operator-SQL-Sample

[![Build DacPacs](https://github.com/cohenjo/operator-sql-sample/actions/workflows/build-dacpacs.yml/badge.svg?branch=master)](https://github.com/cohenjo/operator-sql-sample/actions/workflows/build-dacpacs.yml)

This repo show usage of .sqlproj projects to create sample dacpacs for the [Azure-Schema-Operator](https://microsoft.github.io/azure-schema-operator/).  
The project uses the [SQL: Database Projects extension](https://docs.microsoft.com/en-us/sql/azure-data-studio/extensions/sql-database-project-extension?view=sql-server-ver15)

The `operator-test-*` projects refer to tests of the rollback flow as described [here](./operator-tests.md)  
The other projects are described below.

This repo will generate 3 dacpacs:

1. common dacpac - containing objects in the common schema (used by all tenants)
1. simple-tenant dacpac - containing objects we wish to create per tenant.
1. tenant dacpac - containing objects we wish to create per tenant, with dependancy on the common dacpac

Two more features shown here:

- The tenant dacpac will reference the common dacpac.
- The common dacpac has "post"-script.

To build any of the projects run:

```shell
PROJECT=<project name> task old-build
```

For example:

```shell
PROJECT=operator-tenant task old-build
```

## Operator resources

Creating the ConfigMaps:

```bash
kubectl create configmap operator-common --from-file=dacpac=./operator-tenant/bin/debug/operator-common.dacpac
kubectl create configmap operator-tenant --from-literal templateName="MasterSchema" \
--from-literal externalDacpacs='{ "operator-common": {"name": "operator-common", "namespace": "default"}}' \
--from-literal parallelWorkers="30" \
--from-file=dacpac=./operator-tenant/bin/debug/operator-tenant.dacpac
```

next we need to define `SchemaDeployment` objects that will reference the `ConfigMap`s.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: dbschema.microsoft.com/v1alpha1
kind: SchemaDeployment
metadata:
  name: sql-common-deployment
spec:
  type: sqlServer
  applyTo:
    clusterUris: ['schematest.database.windows.net']
    db: 'db1'
  failIfDataLoss: false
  failurePolicy: abort
  source:
    name: operator-common
    namespace: default
EOF
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: dbschema.microsoft.com/v1alpha1
kind: SchemaDeployment
metadata:
  name: sql-tenant-deployment
spec:
  type: sqlServer
  applyTo:
    clusterUris: ['schematest.database.windows.net']
    db: 'db1'
    schema: db
  failIfDataLoss: true
  failurePolicy: abort
  source:
    name: operator-tenant
    namespace: default
EOF
```

## Simple Tenant

This example will deploy the `operator-simple-tenant` schema on all schemas matching the filter: `db52`.

```bash
kubectl create configmap operator-simple-tenant --from-literal templateName="MasterSchema" \
--from-literal parallelWorkers="30" \
--from-file=dacpac=./operator-simple-tenant/bin/Debug/operator-simple-tenant.dacpac
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: dbschema.microsoft.com/v1alpha1
kind: SchemaDeployment
metadata:
  name: sql-simple-tenant-deployment
spec:
  type: sqlServer
  applyTo:
    clusterUris: ['schematest.database.windows.net']
    db: 'db1'
    schema: db52
  failIfDataLoss: true
  failurePolicy: abort
  source:
    name: operator-simple-tenant
    namespace: default
EOF
```

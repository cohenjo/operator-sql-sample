# Operator tests

In order to test the operator 3 test versions were created.

- Version 1 creates a simple table.
- Version 2 adds an additional column.
- Version err creates an error by changing a String column to a numeric one.

The full test flow should be: v1 => v2 => err (failure) => v2

Usually when developing a sqlproj the different versions will be tags and commits along the product life-cycle - version releases.  
Here, for improved visability we've layed them side-by-side.  
To trigger an error on the column change we need the column to include some data, so v2 contains a post-script which inserts a record.

The operator-test-err dacpac will try to change a `NVARCHAR` field into `INT` which will result in the following error:

> Deploy dacpac: Failed. Could not deploy package. Warning SQL72015: The type for column Name in table [TestTenant].[TestTable1] is currently NVARCHAR (100) NOT NULL but is being changed to INT NOT NULL. Data loss could occur and deployment may fail if the column contains data that is incompatible with type INT NOT NULL. Error SQL72014: Core Microsoft SqlClient Data Provider: Msg 50000, Level 16, State 127, Line 6 Rows were detected. The schema update is terminating because data loss might occur. Error SQL72045: Script execution error. The executed script: IF EXISTS (SELECT TOP 1 1 FROM [TestTenant].[TestTable1]) RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT;

## Building the DacPacks

we need to build 3 projects:

```shell
task build-all
```

Seperate build tasks also exist, see [taskfile](Taskfile.yaml)

This will result in 3 files:

1. `/bin/operator-test-v1.dacpac`
1. `/bin/operator-test-v2.dacpac`
1. `/bin/operator-test-err.dacpac`

These will be used as schema versions in the test.

## Running the test flow

Creating the ConfigMap:

```bash
kubectl create configmap dacpac-test-schema --from-file=dacpac=bin/operator-test-v1.dacpac
```

next we need to define a `SchemaDeployment` object that will reference the `ConfigMap`.  
Note: as we want to run the dacpac on the DB as is - we *must* not specify a schema!

```yaml
cat <<EOF | kubectl apply -f -
apiVersion: dbschema.microsoft.com/v1alpha1
kind: SchemaDeployment
metadata:
  name: sql-test-deployment
spec:
  type: sqlServer
  applyTo:
    clusterUris: ['schematest.database.windows.net']
    db: 'db2'
  failIfDataLoss: true
  failurePolicy: abort
  source:
    name: dacpac-test-schema
    namespace: default
EOF
```

To upgrade the schema to the new version

```shell
kubectl create configmap dacpac-test-schema --save-config --from-file=dacpac=bin/operator-test-v2.dacpac --dry-run=client -o yaml | kubectl apply -f -
```

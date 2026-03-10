# Red Hat Build of Keycloak

- Red Hat build of Keycloak is a cloud-native Identity Access Management solution based on the popular open source Keycloak project. Red Hat build of Keycloak replaces any planned future releases of Red Hat Single Sign-On.

- Documentation: https://docs.redhat.com/en/documentation/red_hat_build_of_keycloak/26.0/

- Create a new project where keycloak will be deployed

```console
oc new-project rhbk --description "Red Hat Build of Keycloak" --display-name "Red Hat Build of Keycloak"
```
- Install the Crunchy Postgres for Kubernetes (Certified) keeping defaults

- Install the Red Hat Build of Keycloak Operator into the rhbk namespace

- Deploy the Posgres Cluster - Installed Operators -> Crunchy Postgres for Kubernetes -> Postgres Cluster and paste the following yaml

```yaml
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: keycloak
  namespace: rhbk
  annotations:
    postgres-operator.crunchydata.com/autoCreateUserSchema: "true"
spec:
  postgresVersion: 16
  instances:
    - name: instance1
      dataVolumeClaimSpec:
        accessModes:
        - "ReadWriteOnce"
        resources:
          requests:
            storage: 1Gi
  backups:
    pgbackrest:
      repos:
      - name: repo1
        volume:
          volumeClaimSpec:
            accessModes:
            - "ReadWriteOnce"
            resources:
              requests:
                storage: 1Gi
```

- Crunchy Operator automatically creates a Secret containing the connection details. Keycloak needs a specific format, so we will reference the secret created by Crunchy (usually named keycloak-pguser-keycloak)
```
oc get secrets -n rhbk
```

- Deploy Red Hat build of Keycloak - Installed Operators -> Red Hat build of Keycloak Operator -> Keycloak and paste the following yaml **The following config is not secure**
```yaml
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: enterprise-rhbk
  namespace: rhbk
spec:
  instances: 1
  additionalOptions:
  - name: http-enabled
    value: "true"
  - name: hostname-strict
    value: "false"
  - name: db-url
    value: jdbc:postgresql://keycloak-primary:5432/keycloak
  db:
    vendor: postgres
    host: keycloak-primary # Crunchy service name
    usernameSecret:
      name: keycloak-pguser-keycloak
      key: user
    passwordSecret:
      name: keycloak-pguser-keycloak
      key: password
  hostname:
    hostname: sso.apps.<cluster FQDN> 
```

- The deployment of the keycloak instance could take several minutes.  Once the route is available log into the console with the initial admin secret
```console
oc get secret main-sso-initial-admin -o jsonpath='{.data.password}' -n rhbk | base64 --decode
```



- Create tlsSecret for keycloak
```console
oc create secret tls keycloak-tls-secret --cert=/path/to/CA.crt --key=/path/to/CA.key -n rhbk
```

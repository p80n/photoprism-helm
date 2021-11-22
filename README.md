# Photoprism Helm Chart
Helm chart to install [PhotoPrism](https://photoprism.org/).

PhotoPrism is a server-based application for browsing, organizing, and sharing your personal photo collection.


## TL;DR;

```bash
helm repo add p80n https://p80n.github.io/photoprism-helm/
helm install photoprism p80n/photoprism --set persistence.enabled=false
```

## Introduction

This chart deploys PhotoPrism to your Kubernetes cluster. It's mostly based off the
[docker-compose](https://github.com/photoprism/photoprism/blob/develop/docker-compose.yml) file
available at [PhotoPrism's GitHub repository](https://github.com/photoprism/photoprism).

Kubernetes is great for running PhotoPrism since there are a lot of k8s tools available to enhance 
the experience:
- [Cert Manager](https://github.com/jetstack/cert-manager) makes it easy to put PhotoPrism behind SSL
- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) makes it easy to expose PhotoPrism with actual URLs
- Running a database as a separate service helps with performance and maintenance.


## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install photoprism p80n/photoprism --create-namespace --namespace photoprism -f values.yaml
```


## Configuration

The following table lists common configurable parameters of the Photoprism chart and their default values.
See values.yaml for a more complete listing.


| Parameter                               | Description    | Default     |
|-----------------------------------------|----------------|--------------|
| <span style="font-family: monospace">adminPassword</span>       | Password for admin account | photoprism |
| <span style="font-family: monospace">existingSecret</span>         | Use existing secret for admin account (key PHOTOPRISM_ADMIN_PASSWORD) | |
| <span style="font-family: monospace">image.repository</span>       | Image repository | <span style="font-family: monospace">photoprism/photoprism</span> |
| <span style="font-family: monospace">image.tag</span>              | Image tag | <span style="font-family: monospace">20210222</span> |
| <span style="font-family: monospace">image.pullPolicy</span>       | Image pull policy | <span style="font-family: monospace">IfNotPresent</span> |
| <span style="font-family: monospace">config</span>                  | Map of environment variables to configure PhotoPrism's runtime behavior | |
| <span style="font-family: monospace">config.PHOTOPRISM_DEBUG</span> | Enable verbose logging | |
| <span style="font-family: monospace">config.PHOTOPRISM_PUBLIC</span> | Allow passwordless access | |
| <span style="font-family: monospace">sidecarContainers</span>      | List of container images to run as sidecars | |
| <span style="font-family: monospace">persistence.enabled</span>    | Enable persistent storage | <span style="font-family: monospace">true</span> |
| <span style="font-family: monospace">persistence.importPath</span> | Path to imported images | <span style="font-family: monospace">/assets/photos/import</span> |
| <span style="font-family: monospace">persistence.originalsPath</span> | Path to pre-existing photos | <span style="font-family: monospace">/assets/photos/originals</span> |
| <span style="font-family: monospace">persistence.storagePath</span> | Location for PhotoPrism to store generated content (e.g., thumbnails) | <span style="font-family: monospace">/assets/photos/originals</span> |
| <span style="font-family: monospace">persistence.volumeMounts</span>  | VolumeMounts for Photoprism | See <span style="font-family: monospace">values.yaml</span> |
| <span style="font-family: monospace">persistence.volumes</span>    | Volumes for Photoprism | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">persistence.volumeClaimTemplates</span> | VolumeClaimTemplate for Photoprism | See <span style="font-family: monospace">values.yaml</span> |
| <span style="font-family: monospace">service.type</span>           | Photoprism service type | <span style="font-family: monospace">ClusterIP</span> |
| <span style="font-family: monospace">service.port</span>           | HTTP to expose service | <span style="font-family: monospace">80</span> |
| <span style="font-family: monospace">ingress.enabled</span>        | Enable ingress rules | <span style="font-family: monospace">false</span> |
| <span style="font-family: monospace">ingress.annotations</span>    | Annotations for ingress | <span style="font-family: monospace">{}</span> |
| <span style="font-family: monospace">ingress.hosts</span>          | Hosts and paths to respond | See <span style="font-family: monospace">values.yaml</span> |
| <span style="font-family: monospace">ingress.tls</span>            | Ingress TLS configuration | <span style="font-family: monospace">[]</span> |
| <span style="font-family: monospace">resources.requests.memory</span> | Indexing photos requires a bit of memory | <span style="font-family: monospace">2Gi</span> |
| <span style="font-family: monospace">database.driver</span>        | <span style="font-family: monospace">mysql</span> or <span style="font-family: monospace">internal</span> are supported | <span style="font-family: monospace">internal</span> |
| <span style="font-family: monospace">database.name</span>          | Remote database name | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">database.user</span>          | Remote database user | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">database.password</span>      | Remote database password | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">database.host</span>          | Remote database host | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">database.port</span>          | Remote database port | <span style="font-family: monospace">nil</span> |
| <span style="font-family: monospace">database.existingSecret</span> | Use existing secret for database DSN (key PHOTOPRISM_DATABASE_DSN) | |


For setting nested values, it's generally easiest to just specify a YAML file that with the correct values:

```bash
$ helm install photoprism p80n/photoprism-helm -f values.yaml
```

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`, but for nested values, it's complicated. For example:
```bash
$ helm install photoprism p80n/photoprism-helm \
    --set=image.tag=latest \
    --set=volumes[0].name=originals --set=volumes[0].nfs.server=my.nfs.server --set=volumes[0].nfs.path=/path
```

## Config
PhotoPrism's configuration can be passed in through environment variables.
To see what is available, you can consult
https://github.com/photoprism/photoprism/blob/develop/docker-compose.yml
or run `docker run photoprism/photoprism photoprism config` to see all possible values.

Note: storage and database configuration, as well as the admin password, should be set
in their appropriate configuration sections. They should not be set here.


## Persistence

It's important to configure persistent storage (e.g., NFS) for any sort of real-world usage.

I've been running PhotoPrism using two NFS shares: one for PhotoPrism's storage cache, and one pointing to where I store my original images in Lightroom (read-only).
This has been working well for me; keeping PhotoPrism assets separate keeps my Lightroom workspace ~~uncluttered~~ less cluttered ;)

If you don't enable persistence, you can still take PhotoPrism for a spin; you'll just have to start from scratch if the pod dies and gets scheduled on a different node.

Note: You can utilize the subPath option of a `volueMount` to only expose a portion of your photo collection. I personally do this, in conjuction with
custom ingress hosts and `PHOTOPRISM_PUBLIC=true`, to share specific galleries with friends with a simple URL (e.g., my-wedding.mydomain.com)


## Database

PhotoPrism can be run without any external dependencies. If no remote database is provided, PhotoPrism will
run SQLite internally. If you enabled persitent storage and specify a value for `persistence.storagePath`, this chart
will automatically configure the SQLite database file to be written to the persistent storage path.

Alternately, if you prefer to run the database separately, you can point PhotoPrism at a MySQL-compatible database
instance (e.g., MySQL, MariaDB, Percona)

## Accessing PhotoPrism

The default values will only expose PhotoPrism inside your cluster on port 80. Some options for accessing PhotoPrism from outside your cluster:
- Configure ingress rules for use with a reverse proxy
- Change the service type to `NodePort` and pick a [free port to expose](https://kubernetes.io/docs/concepts/services-networking/service/)
- Access it from your client with [kubectl port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

## Need Help?

If you have questions about this Helm chart, or have trouble getting it deployed to your cluster, feel free to open an issue.

If you have issues with PhotoPrism itself, you may want to head over to their [issues](https://github.com/photoprism/photoprism/issues) page.

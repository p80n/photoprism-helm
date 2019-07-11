# Photoprism Helm Chart
Helm chart to install [PhotoPrism](https://photoprism.org/).

PhotoPrism is a server-based application for browsing, organizing, and sharing your personal photo collection.


## TL;DR;

```console
helm repo add photoprism-helm https://p80n.github.io/photoprism-helm/
helm install photoprism-helm/photoprism --set persistence=false
```

## Introduction

This chart deploys PhotoPrism to your Kubernetes cluster. It's mostly based off the
[docker-compose](https://github.com/photoprism/photoprism/blob/develop/docker-compose.yml) file
available at [PhotoPrism's GitHub repository](https://github.com/photoprism/photoprism).

This chart includes support for including your existing photos and specifying an ingress.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install p80n/photoprism-helm --name photoprism-test --namespace photoprism-test --set persistence.enabled=false
```


## Configuration

The following table lists the configurable parameters of the Photoprism chart and their default values.
It's worth noting that PhotoPrism is under very active development, so expect the configuration to change.

| Parameter                               | Description    | Default     |
|-----------------------------------------|----------------|--------------|
| <span style="font-family: monospace">image.repository</span>       | Image repository | <span style="font-family: monospace">photoprism/photoprism</span> |
| <span style="font-family: monospace">image.tag</span>              | Image tag | <span style="font-family: monospace">20190703</span> |
| <span style="font-family: monospace">image.pullPolicy</span>       | Image pull policy | <span style="font-family: monospace">IfNotPresent</span> |
| <span style="font-family: monospace">debug</span>                  | Enable verbose logging | <span style="font-family: monospace">true</span> |
| <span style="font-family: monospace">persistence.enabled</span>    | Enable persistent storage | <span style="font-family: monospace">true</span> |
| <span style="font-family: monospace">persistence.cachePath</span>  | Path to image cache | <span style="font-family: monospace">/assets/cache</span> |
| <span style="font-family: monospace">persistence.importPath</span> | Path to imported images | <span style="font-family: monospace">/assets/photos/import</span> |
| <span style="font-family: monospace">persistence.exportPath</span> | Path to exported images | <span style="font-family: monospace">/assets/photos/exports</span> |
| <span style="font-family: monospace">persistence.originalsPath</span> | Path to pre-existing photos | <span style="font-family: monospace">/assets/photos/originals</span> |
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


For setting nested values, it's generally easiest to just specify a YAML file that with the correct values:

```console
$ helm install p80n/photoprism-helm --name my-release -f values.yaml
```

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`, but for nested values, it's complicated. For example:
```console
$ helm install p80n/photoprism-helm --name my-release \
    --set=image.tag=latest \
    --set=volumes[0].name=originals --set=volumes[0].nfs.server=my.nfs.server --set=volumes[0].nfs.path=/path
```



## Persistence

It's important to configure persistent storage (e.g., NFS) for any sort of real-world usage.
I've been running PhotoPrism using two NFS shares: one for PhotoPrism's thumbnails cache, and one pointing to where I store my original images in Lightroom (read-only).
This has been working well for me; keeping PhotoPrism assets separate keeps my Lightroom workspace uncluttered.

If you don't enable persistence, you can still take PhotoPrism for a spin; you'll just have to start from scratch if the pod dies or gets scheduled on a different node.


## Database

PhotoPrism can be run without any external dependencies. If no remote database is provided, PhotoPrism will
run [TiDB](https://github.com/pingcap/tidb) internally.
However, you'll still want to make sure that the database files are stored on persistent storage. See `values.yaml`.

Alternately, if you prefer to run the database separately, you can point PhotoPrism at your remote instance.

> Note:
> Even if your remote database is TiDB, you still specify `mysql` for the driver.

## Accessing PhotoPrism

The default values will only expose PhotoPrism inside your cluster on port 80. Some options for accessing PhotoPrism from outside your cluster:
- Configure ingress rules for use with a reverse proxy
- Change the service type to `NodePort` and pick a free port to expose > 30000
- Access it from your client with [kubectl port-forwar](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

## Need Help?

If you have questions about this Helm chart, or have trouble getting it deployed to your cluster, feel free to open an issue.

If you have issues with PhotoPrism itself, you may want to head over to their [issues](https://github.com/photoprism/photoprism/issues) page.
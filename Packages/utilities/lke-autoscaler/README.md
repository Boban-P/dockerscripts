![Docker Pulls](https://img.shields.io/docker/pulls/bb526/lke-autoscaler)
[![](https://img.shields.io/github/license/Boban-P/dockerscripts.svg)](https://github.com/Boban-P/dockerscripts/blob/main/LICENSE)

## Linode Kubernetes Engine Autoscaler
This is originally cloned from  [meezaan/linode-k8s-autoscaler](https://github.com/meezaan/linode-k8s-autoscaler) and modified.<br>
This is a simple autoscaling utility for horizontally scaling Linodes in an LKE
Cluster Pool based on memory and/or cpu usage. use Kubernetes' horizontal pod autoscaling to scale up pods and this utility to scale up Linodes - this utility let linode cluster scale up or down as needed.

This utility will autoscale based on memory and/or cpu. When using both maximum number of nodes from memory or cpu autoscale is used.

It's fully dockerised (but written in PHP) and has a low resource footprint, so deploy it locally or on the cluster itself.

# Contents
1. [Requirements](#requirements)
2. [Docker Image](#published-docker-image)
3. [Environment Variables & Configuration](#environment-variables--configuration)
4. [Usage](#usage)
5. [Deploying on Kubernetes for Production Use](deploying-on-kubernetes-for-production-use)
6. [Autoscaler Pod Sizing](#sizing-the-autoscaler-pod)

## Requirements
* Linode Kuberenetes Cluster (LKE) with Metrics Server. To deploy metrics server refer [how-can-i-deploy-the-kubernetes-metrics-server-on-lke](https://www.linode.com/community/questions/19756/how-can-i-deploy-the-kubernetes-metrics-server-on-lke)
* A kubectl config file (usually stored @ ~/.kube/config)
* A Linode Personal Access Token with access to LKE
* Docker (optional)

## Published Docker Image
The image for this utility is published @ Docker Hub as bb526/lke-autoscaler (https://hub.docker.com/r/bb526/lke-autoscaler).

## Environment Variables / Configuration
The docker container takes all its configuration via environment variables. Here's a list of what each one does:

| Environment Variable Name | Description  | 
| ------------------------- | ------------ | 
| LINODE_PERSONAL_ACCCESS_TOKEN  | Your Personal Access Token with LKE scope | 
| LINODE_LKE_CLUSTER_ID          | The ID of the LKE Cluster to Autoscale |
| LINODE_LKE_CLUSTER_POOL_ID     | The Node Pool ID within the LKE Cluster to Autoscale |
| LINODE_LKE_CLUSTER_POOL_MINIMUM_NODES | The minimum nodes to keep in the cluster. The cluster won't be scaled down below this.|
| LINODE_LKE_CLUSTER_POOL_MAXIMUM_NODES | The maximum nodes to keep in the cluster. The cluster won't be scaled up above this.|
| AUTOSCALE_MEMORY_UP_PERCENTAGE        | At what percentage of memory to scale up the node pool. Example: 65
| AUTOSCALE_MEMORY_DOWN_PERCENTAGE      | At what percentage of memory to be used after scaling down the node pool. Example: 40
| AUTOSCALE_CPU_UP_PERCENTAGE        | At what percentage of cpu to scale up the node pool. Example: 65
| AUTOSCALE_CPU_DOWN_PERCENTAGE      | At what percentage of cpu to be used after scaling down the node pool. Example: 40
| AUTOSCALE_QUERY_INTERVAL       | How many seconds to wait before each call to the Kubernetes API to check CPU and Memory usage. Example: 10
| AUTOSCALE_THRESHOLD_COUNT      | After how many consecutive matches of AUTOSCALE_UP_PERCENTAGE or AUTOSCALE_DOWN_PERCENTAGE to scale the cluster up or down.
| AUTOSCALE_WAIT_TIME_AFTER_SCALING | How many seconds to wait after scaling up or down to start checking CPU and Memory. This should be set the to give the cluster enough time to adjust itself with the updated number of nodes. Example: 150

To understand the above assuming we have set the following values.
* AUTOSCALE_MEMORY_UP_PERCENTAGE=65
* AUTOSCALE_MEMORY_DOWN_PERCENTAGE=30
* AUTOSCALE_QUERY_INTERVAL=10
* AUTOSCALE_THRESHOLD_COUNT=3
* AUTOSCALE_WAIT_TIME_AFTER_SCALING=180

With this setup, the autoscaler utility will query the Kuberenetes API every 10 seconds. If with 3 consecutive calls
to the API (effectively meaning over 30 seconds), the memory usage is higher than 65%, more node(s) will be added to the
specified node pool so that memmory use remain less than 65%. The utility will wait for 180 seconds and then start 
querying the API every 10 seconds again.

If with 3 consecutive calls to the API (effectively meaning over 30 seconds), the memory usage is lower than 30%,
maximum number of nodes will be removed so that resulting pool will use atmost 30% memmory from the specified node pool.
The utility will wait for 180 seconds and then start querying the API every 10 seconds again.

## Usage

You'll need to configure the Docker image with env variables and the kubectl config.

To run locally:
```
docker run -v ~/.kube/config:/root/.kube/config \
-e LINODE_PERSONAL_ACCCESS_TOKEN='xxxx' \
-e LINODE_LKE_CLUSTER_ID='xxxx' \
-e LINODE_LKE_CLUSTER_POOL_ID='xxxx' \
-e LINODE_LKE_CLUSTER_POOL_MINIMUM_NODES='3' \
-e LINODE_LKE_CLUSTER_POOL_MAXIMUM_NODES='50' \
-e AUTOSCALE_CPU_UP_PERCENTAGE='60' \
-e AUTOSCALE_CPU_DOWN_PERCENTAGE='30' \
-e AUTOSCALE_QUERY_INTERVAL='10' \
-e AUTOSCALE_THRESHOLD_COUNT='3' \
-e AUTOSCALE_WAIT_TIME_AFTER_SCALING='180' bb526/linode-kubernet-autoscaler
```

## Deploying on Kubernetes for Production Use

Build a private Docker image and push a kubectl config file 
with a service account's credentials into the image. So, the Dockerfile may look something like:
```
FROM bb526/lke-autoscaler

COPY configfile /root/.kube/config
```

Once you've built the image (and let's assume it's called yourspace/lke-autoscaler:latest), you can deploy 
it with the following manifest:
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lke-autoscaler
  namespace: name-of-namespace ####### Change this to the actual namespace
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: lke-autoscale
  template:
    metadata:
      labels:
        app: lke-autoscale
    spec:
      imagePullSecrets:
        - name: regcred  ####### Docker registry credentials secret
      containers:
        - name: lke-autoscale
          image: yourspace/lke-autoscaler:latest ####### CHANGE THIS TO YOUR ACTUAL DOCKER IMAGE
          env:
            - name:  LINODE_PERSONAL_ACCCESS_TOKEN
              valueFrom:
                secretKeyRef:
                  name: linode-personal-access-token-lke-autoscaler ####### LINODE PERSONAL ACCESS TOKEN SECRET
                  key: token
            - name:  LINODE_LKE_CLUSTER_ID
              value: ""
            - name:  LINODE_LKE_CLUSTER_POOL_ID
              value: ""
            - name:  LINODE_LKE_CLUSTER_POOL_MINIMUM_NODES
              value: "3"
            - name:  LINODE_LKE_CLUSTER_POOL_MAXIMUM_NODES
              value: "50"
            - name:  AUTOSCALE_MEMORY_UP_PERCENTAGE
              value: "60"
            - name:  AUTOSCALE_MEMORY_DOWN_PERCENTAGE
              value: "30"
            - name:  AUTOSCALE_CPU_UP_PERCENTAGE
              value: "60"
            - name:  AUTOSCALE_CPU_DOWN_PERCENTAGE
              value: "30"
            - name:  AUTOSCALE_QUERY_INTERVAL
              value: "30"
            - name:  AUTOSCALE_THRESHOLD_COUNT
              value: "3"
            - name:  AUTOSCALE_WAIT_TIME_AFTER_SCALING
              value: "150"
          resources:
            requests:
              memory: 32Mi
            limits:
              memory: 32Mi

```

The above manifest uses a secret for
Linode Personal Access Token and docker registry credentials.

You will need to create these.

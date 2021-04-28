## ArgoCD Helm and Argo Workflow

Note: Argo CD will not use helm install to install charts. It will render the chart with helm template and then apply the output yaml files.

Local quickstart

Prerequisites

- Docker
- argocd client ( brew install argocd )
- helm v3 ( brew install helm )
- k3d ( brew install k3d )


```sh

k3d cluster create argo-brownbag -a 3

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Or using helm v3 ( not validated )
 
helm repo add argo https://argoproj.github.io/argo-helm
helm install k3d argo/argo-cd -n argocd --create-namespace=true --installCRDs=false


#access ui on localhost:8888 in seperate terminal
while true ; do kubectl port-forward svc/argocd-server 8888:80 -n argocd; sleep 5 ; done

# update the admin password / portfowarding must be running
argopwd=$( kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d - )
argocd login localhost:8888 --username admin --password=${argopwd}
argocd account update-password --current-password=${argopwd}



```
# if using private git repo
- create an ssh key
- add public key to bitbucket project
- deploy the secret key and repo

eg:
```sh

argocd repo add git@github.com:jrhoward/argo-sample-app.git --ssh-private-key-path ~/.ssh/id_rsa_argo

# or for a public repo

argocd repo add https://github.com/jrhoward/argo-sample-app.git

```

Add helm repositories that are used, eg.

```sh

kubectl edit configmap -n argocd argocd-cm

```

patch the configmap with required helm repositories:

```yaml

repositories: |
  - type: helm
    name: hashicorp
    url: https://helm.releases.hashicorp.com
  - type: helm
    name: argo-sample-app
    url: https://jrhoward.github.io/argo-sample-app
```

Create Argo workflow

```
kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml


while true ; do kubectl -n argo port-forward deployment/argo-server 2746:2746; sleep 5 ; done

workflow will be available at https://localhost:2746

```

change the `containerRuntimeExecutor` in the configMap `workflow-controller-configmap` to pns , default is Docker:

```
data:
   containerRuntimeExecutor: pns
```

deploy the sample workflow template

```

kubectl apply -f custom-apps/workflow-event/smoketest-workflow-template.yaml

```

deploy the custom app of apps

```
kubectl apply -f custom-apps/custom-app-base/app-of-apps.yaml

```

review finalizer set up. Do you want to cascade delete when an Application custom resource is deleted ?
```yaml
  finalizers:
  - resources-finalizer.argocd.argoproj.io
```

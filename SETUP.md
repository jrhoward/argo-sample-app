## ArgoCD Helm and Argo Workflow

Local quickstart

Prerequisites

- Docker
- argocd client ( brew install argocd )
- helm v3 ( brew install helm )
- k3d ( brew install k3d )
- kubectl


```sh
# Launch a local cluster
k3d cluster create argo-brownbag -a 3



# Or using helm v3 ( NOT VALIDATED )
 
helm repo add argo https://argoproj.github.io/argo-helm
helm install cluster argo/argo-cd -n argocd --create-namespace=true --set=installCRDs=false -f ../kube-bootstrap/terraform/k8s/manifests/argo-overrides/argo-values.yaml


#access UI on localhost:8888 in seperate terminal
while true ; do kubectl port-forward svc/cluster-argocd-server 8888:80 -n argocd; sleep 1 ; done

# update the admin password / portfowarding must be running
argopwd=$( kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d - )
argocd login localhost:8888 --username admin --password=${argopwd}
argocd account update-password --current-password=${argopwd}



```
if using private git repo

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

Argo workflow is deployed automatically

```sh

while true ; do kubectl -n argo port-forward deployment/argo-server 2746:2746; sleep 1 ; done

# workflow UI will be available at https://localhost:2746

```
The `containerRuntimeExecutor` in the configMap `workflow-controller-configmap` is automatically configured:

```yaml
data:
   containerRuntimeExecutor: pns
```

The sample workflow template is automatically deployed: smoketest-workflow-template.yaml


deploy the custom app of apps

```sh
kubectl apply -f custom-apps/custom-app-base/app-of-apps.yaml
````

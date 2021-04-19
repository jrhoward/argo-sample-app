## ArgoCD Helm Notes

Note: Argo CD will not use helm install to install charts. It will render the chart with helm template and then apply the output with kubectl.

quickstart locally

```sh

k3d cluster create -a 3

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# OR

helm repo add argo https://argoproj.github.io/argo-helm
helm install --name k3d argo/argo-cd -n argocd --create-namespace=true --installCRDs=false

#access ui on localhost:8888
kubectl port-forward svc/k3d-argocd-server 8888:80 -n argocd
# brew install argocd

# update the admin password / portfowarding must be running
argopwd=$( kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[*].metadata.name}' )
argocd login localhost:8888 --username admin --password=${argopwd}
argocd account update-password --current-password=${argopwd}

#access ui on localhost:8888
while true ; do kubectl port-forward svc/argocd-server 8888:80 -n argocd; sleep 5 ; done

# UI is available at localhost:8888 in web browser

```

- create an ssh key
- add public key to bitbucket project
- deploy the secret key and repo

eg:
```sh

argocd repo add git@[repo url]/argo-sample-app.git --ssh-private-key-path ~/.ssh/id_rsa_argo

```

For chart dependencies `ADD` to work ( umbrella charts ) the helm repo must be configured in argo eg:

```sh

kubectl edit configmap -n argocd argocd-cm

```

patch the configmap with required helm repositories:

```yaml

repositories: |
  - type: helm
    name: vault
    url: https://helm.releases.hashicorp.com
```

review finalizer set up
```yaml
  finalizers:
  - resources-finalizer.argocd.argoproj.io
```


## Argo Workflow

```
kubectl create ns argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml


while true ; do kubectl -n argo port-forward deployment/argo-server 2746:2746; sleep 5 ; done

```
note: change the `containerRuntimeExecutor` in the configMap to pns , not Docker, see: https://github.com/argoproj/argo-workflows/blob/master/docs/workflow-executors.md

https://github.com/argoproj/argo-workflows/blob/master/docs/workflow-controller-configmap.yaml


responses can be taken from Artifact repository https://argoproj.github.io/argo-workflows/configure-artifact-repository/

see example: https://github.com/sandeepbhojwani/argo/commit/8aee04560514f3882aff1e6e3ffb3cf4447bafc7#diff-4d35bfe66ae0cddc746fba89805c8d6bccc67cbd2d4864ef6bfb2546169ff8a1
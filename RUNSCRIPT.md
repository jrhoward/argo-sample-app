
```sh
k3d cluster start argo-brownbag
kubectx k3d-argo-brownbag
kubectl cluster-info
```
in seperate terminals

```sh
while true ; do kubectl port-forward svc/argocd-server 8888:80 -n argocd; sleep 1 ; done

while true ; do kubectl -n argo port-forward deployment/argo-server 2746:2746; sleep 1 ; done
```

- Bootstrap by deploying App of Apps

```sh
kubectl apply -f custom-apps/custom-app-base/app-of-apps.yaml

```
- Explore Deployment and Workflow with Lifecycle Hook

- note custom-app-1 is autosynced

- change custom-app-1 image to nginx:1.17

```sh
kubectl edit deployment -n argo-samples custom-app-1
```

- review autosync from UI

- review autosync from console

```sh
kubectl edit deployment -n argo-samples custom-app-1
```

- note image has been reverted back to original

- Apply Manual Sync to custom-app-2 from Argo UI

- Apply Manual Sync to custom-app-3 via API

```sh
argocd login localhost:8888 --username admin --password=password

argocd app sync custom-app-3 --revision HEAD
```

- change the image tag in custom-app-2 to "1.17" via git commit

```sh
vi custom-apps/custom-app-set/chart/values/dev/custom-app-2.yaml

gitall 'change custom-app-2 image to v1.17'
```

- View diff and sync process in UI.


- Review Umbrella Chart technique for third party helm charts See: `third-party/vault-set/chart/`

- Cleanup 

```sh
kubectl delete -f custom-apps/custom-app-base/app-of-apps.yaml

k3d cluster stop argo-brownbag
```


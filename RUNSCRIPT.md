kubectx k3d-argo-brownbag
kubectl cluster-info

split pane vertically
split pane horizontally
```sh
while true ; do kubectl port-forward svc/argocd-server 8888:80 -n argocd; sleep 5 ; done

while true ; do kubectl -n argo port-forward deployment/argo-server 2746:2746; sleep 5 ; done
```

- Deploy App of Apps

```sh
kubectl apply -f custom-apps/custom-app-base/app-of-apps.yaml

```
- Explore Deployment and Workflow
- note custom-app-1 is autosynced

- change custom-app-1

```sh
kubectl edit deployment -n alpha-platform custom-app-1
```

- change image to nginx:1.18

- review autosync from UI

- review autosync from console

kubectl edit deployment -n alpha-platform custom-app-1

- note image has been reverted back to original

- Apply Sync to custom-app-2 from Argo UI

- Sync via API

```
argocd login localhost:8888 --username admin --password=password

argocd app sync custom-app-3 --revision HEAD
```

- change the image tag in custom-app-1 to "1.17"

```sh
vi custom-apps/custom-app-set/chart/values/dev/custom-app-1.yaml

gitall 'change custom-app-1 image to v1.17'
```

- View sync process in UI

- Cleanup 

```sh
kubectl delete -f custom-apps/custom-app-base/app-of-apps.yaml
```
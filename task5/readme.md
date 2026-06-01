## Запуск minikube
```bash
minikube start --cni=calico
```
## Разворачивание сервисов с требуемыми метками:
```bash
# front-end
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80

# back-end-api
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80

# admin-front-end
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80

# admin-back-end-api
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```

## Применение сетевой политики:
```bash
kubectl apply -f non-admin-api-allow.yaml
```

## Проверка доступов между нужными сервисами:
```bash
kubectl run test-front --rm -i -t --image=alpine --labels role=front-end -- sh
#успех:
wget -qO- --timeout=2 http://back-end-api-app
#неуспех (таймаут):
wget -qO- --timeout=2 http://admin-back-end-api-app

exit;

kubectl run test-front --rm -i -t --image=alpine --labels role=admin-front-end -- sh
#неуспех (таймаут):
wget -qO- --timeout=2 http://back-end-api-app
#успех:
wget -qO- --timeout=2 http://admin-back-end-api-app

exit;
```
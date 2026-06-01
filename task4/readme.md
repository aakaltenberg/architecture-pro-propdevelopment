## Запуск minikube, создание пространств имен

```bash
minikube start
kubectl create ns sales
kubectl create ns utilities
kubectl create ns finance
kubectl create ns data
```

## Создание пользователей

```bash
.\create-users.ps1
```

## Создание ролей, и биндинга ролей к пользователям

```bash
kubectl apply -f create-roles.yaml
kubectl apply -f create-bindings.yaml
```

## Для добавления пользователей в кластер использовал следующие команды:
```bash
kubectl config set-credentials test_user_role --client-certificate=.\certs\test_user_role.crt --client-key=.\certs\test_user_role.key --embed-certs
kubectl config set-credentials test_dev_sales_role --client-certificate=.\certs\test_dev_sales_role.crt --client-key=.\certs\test_dev_sales_role.key --embed-certs
kubectl config set-credentials test_secure_role --client-certificate=.\certs\test_secure_role.crt --client-key=.\certs\test_secure_role.key --embed-certs
kubectl config set-credentials test_admin_role --client-certificate=.\certs\test_admin_role.crt --client-key=.\certs\test_admin_role.key --embed-certs

kubectl config set-context test-user-view --cluster=minikube --user=test_user_role
kubectl config set-context test-dev-sales --cluster=minikube --user=test_dev_sales_role
kubectl config set-context test-secure --cluster=minikube --user=test_secure_role
kubectl config set-context test-admin --cluster=minikube --user=test_admin_role
```

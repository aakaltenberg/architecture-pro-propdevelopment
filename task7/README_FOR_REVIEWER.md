
```bash
#с minikube не работает, используем kind:
# Создать простой кластер
kind create cluster --config kind-simple.yaml

# Скопировать audit-policy.yaml:
docker cp .\audit-config\audit-policy.yaml kind-control-plane:/etc/kubernetes/pki/audit-policy.yaml

# Обновить манифест kube-apiserver:
docker cp kind-control-plane:/etc/kubernetes/manifests/kube-apiserver.yaml .\kube-apiserver.yaml

#Добавляем строки:
    - --audit-policy-file=/etc/kubernetes/pki/audit-policy.yaml
    - --audit-log-path=/var/log/audit.log
    - --audit-log-maxsize=10
    - --audit-log-maxbackup=1

#Сохраняем файл обратно:
docker cp .\kube-apiserver.yaml kind-control-plane:/etc/kubernetes/manifests/kube-apiserver.yaml
```

## Структура проекта

- `01-create-namespace.yaml` – создание пространства `audit-zone` с PSA `restricted`.
- `insecure-manifests/` – три пода, нарушающих политики: privileged, hostPath, root.
- `secure-manifests/` – исправленные версии, соответствующие restricted и Gatekeeper.
- `gatekeeper/` – шаблоны и ограничения OPA Gatekeeper для предотвращения привилегированного режима, hostPath и runAsNonRoot.
- `verify/` – скрипты для автоматической проверки работы admission и Gatekeeper.
- `audit-policy.yaml` – минимальная политика аудита.


После того, как кластер запущен, можно проверять.

```bash
# Создаем неймспейс:
kubectl apply -f 01-create-namespace.yaml

# установить OPA Gatekeeper
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml

# применить Constraint Templates и Constraints
kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/

#запустить проверку небезопасных подов:
bash verify/verify-admission.sh
#Ожидается, что все три пода будут отклонены.

#применить безопасные поды
kubectl apply -f secure-manifests/

# запустить проверку Gatekeeper
bash verify/validate-security.sh
```
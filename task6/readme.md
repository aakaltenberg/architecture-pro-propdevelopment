## Настройка окружения
```bash
cd C:\architecture-pro-propdevelopment\task6

#с minikube не работает, используем kind:
```bash
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

#Проверяем, что кластер в порядке:
kubectl get pods -n kube-system
```
#файл audit-policy.yaml также пришлось поправить, т.к. в исходной версии не работает. В актуальной версии ругается на "*" в блоке group


```

## Выполнение симуляции инцидентов
```bash
bash simulate-incident.sh
```
### Результат:

```bash
$ bash simulate-incident.sh
namespace/secure-ops created
Context "kind-kind" modified.
serviceaccount/monitoring created
pod/attacker-pod created
no
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:secure-ops:monitoring" cannot list resource "secrets" in API group "" in the namespace "kube-system"
pod/privileged-pod created
error: Internal error occurred: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "b54c69896268a73184fe06bbc83c5b34ac17577af55dad5b10d065693b81c916": OCI runtime exec failed: exec failed: unable to start container process: exec: "cat": executable file not found in $PATH
error: resource mapping not found for name: "" namespace: "" from "C:/Program Files/Git/etc/kubernetes/audit-policy.yaml": no matches for kind "Policy" in version "audit.k8s.io/v1"
ensure CRDs are installed first
rolebinding.rbac.authorization.k8s.io/escalate-binding created
```
В ходе выполнения всплыло несколько ошибок, которые, вероятно, обусловлены "обрезанной" версией kind, и отсутствием в окружении требуемых приложений

### копирование логов в локальный каталог
```bash
docker exec kind-control-plane cat /var/log/kubernetes/audit.log > audit.log 
```

## выполнение аудита с помощью скрипта:
```bash
./analyze-audit.sh audit.log
```
### Результат:
```bash
Extracted suspicious events to audit-extract.json
============================================
Total unique suspicious events: 20
Details by type:
  - Secrets access (get):          0
  - kubectl exec into pods:        0
  - Privileged pods:               5
  - Audit policy changes:          15
============================================
```




#!/bin/bash
echo "Проверка admission (insecure поды должны быть отклонены)"

check_deny() {
  local file=$1
  local desc=$2
  output=$(kubectl apply -f "$file" 2>&1)
  if echo "$output" | grep -qE 'denied|Forbidden|violates'; then
    echo "✅ $desc отклонён"
  else
    echo "❌ $desc НЕ отклонён! Вывод:"
    echo "$output"
  fi
}

check_deny "../insecure-manifests/01-privileged-pod.yaml" "Привилегированный под"
check_deny "../insecure-manifests/02-hostpath-pod.yaml" "HostPath под"
check_deny "../insecure-manifests/03-root-user-pod.yaml" "Root под"
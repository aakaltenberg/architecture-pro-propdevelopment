#!/bin/bash
echo "Проверка secure подов и Gatekeeper"

if kubectl get pods -n gatekeeper-system 2>/dev/null | grep -q gatekeeper; then
  echo "✅ Gatekeeper запущен"
else
  echo "❌ Gatekeeper НЕ запущен!"
fi

kubectl apply -f ../secure-manifests/01-secure.yaml && echo "✅ 01-secure создан" || echo "❌ 01-secure ошибка"
kubectl apply -f ../secure-manifests/02-secure.yaml && echo "✅ 02-secure создан" || echo "❌ 02-secure ошибка"
kubectl apply -f ../secure-manifests/03-secure.yaml && echo "✅ 03-secure создан" || echo "❌ 03-secure ошибка"

echo "Подов в audit-zone:"
kubectl get pods -n audit-zone
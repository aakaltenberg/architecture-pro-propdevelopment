# create-users.ps1
$ErrorActionPreference = "Stop"

$caCert = "$env:USERPROFILE\.minikube\ca.crt"
$caKey  = "$env:USERPROFILE\.minikube\ca.key"

if (-not (Test-Path $caCert)) { throw "CA cert не найден: $caCert" }
if (-not (Test-Path $caKey))  { throw "CA key не найден: $caKey" }

mkdir certs -Force | Out-Null

function New-KubeUserCert {
    param($name, $group)
    openssl genrsa -out certs\$name.key 2048
    openssl req -new -key certs\$name.key -out certs\$name.csr -subj "/CN=$name/O=$group"
    openssl x509 -req -in certs\$name.csr -CA $caCert -CAkey $caKey -CAcreateserial -out certs\$name.crt -days 365
    Write-Host "Создан $name (группа $group)"
}

New-KubeUserCert "test_user_role" "viewers"
New-KubeUserCert "test_dev_sales_role" "developers-sales"
New-KubeUserCert "test_secure_role" "security"
New-KubeUserCert "test_admin_role" "cluster-admins"

Write-Host "Готово. Сертификаты в папке certs"
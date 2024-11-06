# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Frontend

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

## Backend

```bash
go run ./cmd/api
go test -v ./... 
```
# Инструкции
**URL продуктивной инсталляции:** https://89.169.162.219.sslip.io/

**URL grafana:**

## TODO (БЭКЛОГ): 
- Пересобрать образ trivy c БД. Сейчас джобы иногда падают при привышении лимитов загрузки БД уязвимостей. 

## Репозиторий
Данный репозиторий представляет собой единый репозиторий для исходного кода приложения и кода инфраструктуры интернет-магазина Пельменная №2.

## Внесение изменений
Для внесения изменений необходимо создать feature ветку и вносить изменения в ней. После завершения разработки новой функциональности необходимо слить (сделать MergeRequest) в main ветку

## Правила версионирования
- Для версионирования прилоежния используется SemVer.
- Минорные и мажорные версии устанавливаются вручную в переменной `VERSION` в файлах .gitlab-ci.yml
- Патч версии устанавливаются автоматически. Используется значение переменной `CI_PIPELINE_ID`

## CI/CD
Для приложения реализован CI/CD pipeline, включающий в себя этапы `pre-build`, `build`, `test`, `deploy`.

На этапе `pre-build` проводятся такике проверки информационной безопасности:
- Статичeский анализ исходного кода (SAST) с использованием `semgrep`
- Поиск секретов с использованием `gitleaks`
- Компоненный анализ (SCA) с использованием `trivy`

На этапе `build` происходит сборка контейнеров.

На этапе `test` проходит еще одна проверка безопасности - поиск уязвиомостей в компонентах собранного контейнера.

На этапе `deploy` происходит развертывание приложения.

## Развертывние K8s
Для развертывания Kubernetes использовать **terraform**. 

Предварительно нужно выполнить:
- в Yandex Cloud создать сервисный аккаунт `sa-terraform` с ролями `admin`и `editor`, получить статический ключ доступа, сохранить секретный ключ в переменные `access_key` и `secret_key` в файле `infrastructure/terraform/backend.tfvars`
- получить iam-token (команда `yc iam create-token`), сохранить в переменную `token` в файле `infrastructure/terraform/secret.tfvars`
- в Yandex Cloud создать Object Storage, внести параметры подключения в файл `infrastructure/terraform/provider.tf`

Затем выполнить следующие комманды:
```
cd infrastructure/terraform
terraform init -backend-config=backend.tfvars
terraform apply -var-file="secret.tfvars"
```

## Настройка kubectl
Для получения учетных данных для подключения к кластеру необходимо выполнить следующую команду:
```
yc managed-kubernetes cluster get-credentials --id <cluster_id> --external
```
`cluster_id` можно узнать в веб интерфейсе yandex cloud или в выводе terraform:
```
yandex_kubernetes_cluster.k8s_zonal_cluster: Creation complete after 9m1s [id=<cluster_id>]
```

Для того, чтобы runner GitLab мог развертывать приложение во вновь развернутый кластер k8s необходимо:
- создать сервисный аккаунт `kubectl apply -f infrastructure\service-account\sa.yaml`
- подготовить файл kubeconfig согласно [инструкции](https://yandex.cloud/ru/docs/managed-kubernetes/operations/connect/create-static-conf)
- записать полученный kubeconfig (предварительно закодировав в base64) в переенную Gitlab `KUBE_CONFIG`

## Настройка GitLab
Для коректной работы CI/CD необходимо заполнить значения следующих переменных GitLab:
- KUBE_CONFIG
- NEXUS_USER
- NEXUS_PASS
- NEXUS_HELM_REPO

## Установка приложения
1. cоздаем namespace для нашего магазина.
```
kubectl create namespace momo-store
```
2. устанавливаем cert-manager
```
cd infrastructure/momo-store-chart/
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install --atomic -n momo-store cert-manager jetstack/cert-manager --set installCRDs=true
```
3. устанавливаем приложение, указав версии образов контейенеров backend и frontend
```
helm dependency build
helm upgrade --install --atomic -n momo-store momo-store . --set backend.image.tag=latest --set frontend.image.tag=latest
```
Тег `latest` может быть заменен на другой доступный в GitLab registry

## Мониторинг
Здесь будет описание grafana + prometheus.
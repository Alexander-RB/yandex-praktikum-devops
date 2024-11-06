# monitoring

Установка prometheus, grafana, alertmanager
1.  helm upgrade --install prometheus --namespace {{ название неймспейса }} prometheus
2.  helm upgrade --install grafana --namespace {{ название неймспейса }} grafana
3.  helm upgrade --install alertmanager --namespace {{ название неймспейса }} alertmanager

* Пароль по умолчанию от Grafana


* admin\admin


* Формирование урлов для внешнего подключения
* {{ .Release.Namespace }}-monitoring.k8s.praktikum-services.tech - prometheus
* {{ .Release.Namespace }}-grafana.k8s.praktikum-services.tech - grafana
* {{ .Release.Namespace }}-alertmanager.k8s.praktikum-services.tech - alertmanager

Структура чартов

```
├── alertmanager
│   ├── Chart.yaml
│   ├── templates
│   │   ├── _helpers.tpl
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── services.yaml
│   └── values.yaml
├── grafana
│   ├── Chart.yaml
│   ├── templates
│   │   ├── _helpers.tpl
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── pvc.yaml
│   │   └── services.yaml
│   └── values.yaml
└── prometheus
    ├── Chart.yaml
    ├── prom-app-example.yaml
    ├── rules
    │   └── test.rules
    ├── templates
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   ├── ingress.yaml
    │   ├── rules.yaml
    │   └── services.yaml
    └── values.yaml
```